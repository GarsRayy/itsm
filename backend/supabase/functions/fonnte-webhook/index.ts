import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

// ── Environment ───────────────────────────────────────────────────────────────
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const fonnteToken = Deno.env.get('FONNTE_TOKEN')!

// ── Types ─────────────────────────────────────────────────────────────────────
interface UserProfile {
  id: string
  full_name: string
  phone_number: string | null
  email: string
  division: string | null
}

interface WaSession {
  phone_number: string
  state: 'idle' | 'awaiting_email' | 'awaiting_main_menu' | 'awaiting_satker' | 'awaiting_judul' | 'awaiting_deskripsi' | 'awaiting_foto' | 'awaiting_faq'
  satker?: string
  judul?: string
  deskripsi?: string
  profile_id?: string | null
}

// ── Fonnte Reply Helper ───────────────────────────────────────────────────────
async function sendWa(target: string, message: string): Promise<void> {
  if (!fonnteToken) return
  await fetch('https://api.fonnte.com/send', {
    method: 'POST',
    headers: {
      'Authorization': fonnteToken,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ target, message }),
  })
}

// ── Session Helpers ───────────────────────────────────────────────────────────
async function getSession(supabase: SupabaseClient, phone: string): Promise<WaSession | null> {
  const { data } = await supabase
    .from('wa_sessions')
    .select('*')
    .eq('phone_number', phone)
    .maybeSingle()
  return data as WaSession | null
}

async function upsertSession(supabase: SupabaseClient, session: Partial<WaSession> & { phone_number: string }): Promise<void> {
  const { error } = await supabase
    .from('wa_sessions')
    .upsert({ ...session, updated_at: new Date().toISOString() }, { onConflict: 'phone_number' })
  
  if (error) {
    console.error('UPSERT ERROR:', error)
    throw new Error(`Failed to update session: ${error.message}`)
  }
}

async function clearSession(supabase: SupabaseClient, phone: string): Promise<void> {
  await supabase
    .from('wa_sessions')
    .delete()
    .eq('phone_number', phone)
}

// ── Ticket Creator ────────────────────────────────────────────────────────────
async function createTicket(
  supabase: SupabaseClient,
  profile: UserProfile,
  satker: string,
  judul: string,
  deskripsi: string,
  fotoUrl: string | null
): Promise<string> {
  const satkerCode = satker === 'Layanan IT' ? 'IT' : satker === 'Layanan Umum' ? 'UM' : 'SDM'
  
  const now = new Date()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const year = String(now.getFullYear()).slice(-2)
  const prefix = `L-${satkerCode}-${month}${year}`

  // Cari urutan terakhir bulan ini
  const { data: lastTicket } = await supabase
    .from('tickets')
    .select('ticket_code')
    .like('ticket_code', `${prefix}%`)
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle()

  let urut = 1
  if (lastTicket && lastTicket.ticket_code) {
    const lastUrutStr = lastTicket.ticket_code.slice(-3)
    const lastUrut = parseInt(lastUrutStr, 10)
    if (!isNaN(lastUrut)) urut = lastUrut + 1
  }

  const ticketCode = `${prefix}${String(urut).padStart(3, '0')}`

  const { error } = await supabase.from('tickets').insert({
    ticket_code: ticketCode,
    phone_number: profile.phone_number,
    reporter_name: profile.full_name,
    title: judul, // Judul sudah terisi dari WaSession.judul
    description: deskripsi,
    attachment_url: fotoUrl, // assuming there's a column for it
    source: 'whatsapp',
    origin: 'whatsapp', // Field origin baru sesuai schema
    organization_name: profile.division ?? 'Internal',
    status: 'new', // new for Triage
    priority: 'medium', // Default to medium until Leader validates
    user_profile_id: profile.id,
    // Note: satker could map to a service_catalog ID if desired, but we leave it as is or omit it based on schema
  })

  if (error) {
    console.error("Insert error:", error)
    throw error
  }
  return ticketCode
}

// ── Main Handler ──────────────────────────────────────────────────────────────
serve(async (req: Request) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  try {
    const body = await req.json()
    const sender: string = body.sender ?? ''
    const rawMessage: string = (body.message ?? '').trim()
    const attachment: string | null = body.url ?? null // Fonnte URL for attachment

    if (!sender || !rawMessage && !attachment) {
      return new Response('Missing sender or message/attachment', { status: 400 })
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // ── CEK STATUS TIKET (GLOBAL COMMAND) ─────────────────
    if (rawMessage.toUpperCase().startsWith('CEK L-')) {
      const checkCode = rawMessage.toUpperCase().replace('CEK ', '').trim()
      const { data: ticket } = await supabase
        .from('tickets')
        .select('ticket_code, title, status')
        .eq('ticket_code', checkCode)
        .maybeSingle()

      if (ticket) {
        await sendWa(sender, `🎫 *${ticket.ticket_code}*\n📝 ${ticket.title}\n📊 Status: *${ticket.status.toUpperCase()}*`)
      } else {
        await sendWa(sender, `⚠️ Tiket dengan kode *${checkCode}* tidak ditemukan.`)
      }
      return new Response(JSON.stringify({ status: 'cek_tiket' }), { headers: { 'Content-Type': 'application/json' } })
    }

    // Reset keywords
    const resetKeywords = ['batal', 'cancel', 'menu', 'mulai', 'start', '0']
    if (resetKeywords.includes(rawMessage.toLowerCase()) && !attachment) {
      await clearSession(supabase, sender)
    }

    let session = await getSession(supabase, sender)
    let currentState = session?.state ?? 'idle'

    // ── PENGECEKAN PROFIL (WA TERDAFTAR) ──────────────────
    let profile: UserProfile | null = null
    const { data: existingProfile } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('phone_number', sender)
      .eq('is_active', true)
      .maybeSingle()

    profile = existingProfile

    if (!profile) {
      if (currentState !== 'awaiting_email') {
        // Minta Email
        await upsertSession(supabase, {
          phone_number: sender,
          state: 'awaiting_email',
        })
        await sendWa(sender, `⚠️ Nomor Anda belum terdaftar di sistem ITSM.\n\nSilakan balas dengan *Alamat Email Resmi Perusahaan* Anda untuk verifikasi.`)
        return new Response(JSON.stringify({ status: 'asked_email' }), { headers: { 'Content-Type': 'application/json' } })
      } else {
        // Proses validasi Email
        const { data: emailProfile } = await supabase
          .from('user_profiles')
          .select('*')
          .eq('email', rawMessage.toLowerCase())
          .eq('is_active', true)
          .maybeSingle()

        if (emailProfile) {
          // Tautkan nomor WA
          await supabase.from('user_profiles').update({ phone_number: sender }).eq('id', emailProfile.id)
          profile = { ...emailProfile, phone_number: sender }
          await clearSession(supabase, sender)
          currentState = 'idle'
          await sendWa(sender, `✅ Email berhasil diverifikasi. Nomor Anda telah ditautkan.`)
        } else {
          await clearSession(supabase, sender)
          await sendWa(sender, `❌ Email tidak ditemukan di sistem. Silakan hubungi pihak IT untuk meregistrasikan akun Anda ke dalam database.`)
          return new Response(JSON.stringify({ status: 'email_not_found' }), { headers: { 'Content-Type': 'application/json' } })
        }
      }
    }

    if (!profile) return new Response(JSON.stringify({ status: 'unauthorized' }), { headers: { 'Content-Type': 'application/json' } })

    // ── STATE: idle → tampilkan main menu ─────────────────
    if (currentState === 'idle') {
      await upsertSession(supabase, {
        phone_number: sender,
        state: 'awaiting_main_menu',
        profile_id: profile.id,
      })

      await sendWa(
        sender,
        `Halo *${profile.full_name}*! 👋\n\nSelamat datang di *Layanan Terintegrasi (ITSM)* 🛠️\n\n` +
        `Silakan pilih menu (balas angka 1, 2, atau 3):\n` +
        `  1. 🛠️ Buat Laporan Pengaduan\n` +
        `  2. 💡 Bantuan Penggunaan\n` +
        `  3. 🔍 Cek Status (Ketik CEK [Nomor Tiket])\n\n` +
        `_Balas *0* atau *batal* kapan saja untuk kembali._`
      )

      return new Response(JSON.stringify({ status: 'sent_main_menu' }), { headers: { 'Content-Type': 'application/json' } })
    }

    // ── STATE: awaiting_main_menu ─────────────────
    if (currentState === 'awaiting_main_menu') {
      const choice = parseInt(rawMessage, 10)

      if (choice === 1) {
        await upsertSession(supabase, {
          phone_number: sender,
          state: 'awaiting_satker',
          profile_id: profile.id,
        })
        await sendWa(sender, `Silakan pilih *Satuan Kerja (Satker)* yang dituju (balas angka):\n\n  1. Layanan IT\n  2. Layanan Umum\n  3. Layanan SDM\n\n_Balas *0* untuk kembali ke awal._`)
        return new Response(JSON.stringify({ status: 'sent_satker_menu' }), { headers: { 'Content-Type': 'application/json' } })
      } else if (choice === 2) {
        await upsertSession(supabase, { phone_number: sender, state: 'awaiting_faq', profile_id: profile.id })
        await sendWa(sender, `*💡 Bantuan Penggunaan*\n\n1. 🤖 Cara Lapor\n2. 🔑 Cara Reset Password\n\n_Balas *0* untuk kembali ke awal._`)
        return new Response(JSON.stringify({ status: 'sent_faq_menu' }), { headers: { 'Content-Type': 'application/json' } })
      } else if (choice === 3) {
        await clearSession(supabase, sender)
        await sendWa(sender, `Untuk melacak tiket, cukup kirimkan pesan dengan format:\n*CEK [Nomor Tiket]*\nContoh: CEK L-IT-0626001\n\n_Ketik *mulai* untuk kembali ke menu utama._`)
        return new Response(JSON.stringify({ status: 'sent_tracking_info' }), { headers: { 'Content-Type': 'application/json' } })
      } else {
        await sendWa(sender, `⚠️ Pilihan tidak valid.`)
        return new Response(JSON.stringify({ status: 'invalid_choice' }), { headers: { 'Content-Type': 'application/json' } })
      }
    }

    // ── STATE: awaiting_satker ─────────────────
    if (currentState === 'awaiting_satker') {
      const choice = parseInt(rawMessage, 10)
      const satkers = ['Layanan IT', 'Layanan Umum', 'Layanan SDM']
      if (isNaN(choice) || choice < 1 || choice > 3) {
        await sendWa(sender, `⚠️ Pilihan tidak valid. Mohon balas angka 1, 2, atau 3.`)
        return new Response(JSON.stringify({ status: 'invalid_choice' }), { headers: { 'Content-Type': 'application/json' } })
      }
      
      const satker = satkers[choice - 1]
      await upsertSession(supabase, {
        phone_number: sender,
        state: 'awaiting_judul',
        satker: satker,
        profile_id: profile.id,
      })
      await sendWa(sender, `Anda memilih: *${satker}*\n\nTahap 1/3: 📝 Mohon ketikkan *Judul Laporan* Anda dalam satu pesan (Contoh: "Internet Mati di Lantai 2").`)
      return new Response(JSON.stringify({ status: 'asked_judul' }), { headers: { 'Content-Type': 'application/json' } })
    }

    // ── STATE: awaiting_judul ─────────────────
    if (currentState === 'awaiting_judul') {
      await upsertSession(supabase, {
        phone_number: sender,
        state: 'awaiting_deskripsi',
        judul: rawMessage,
      })
      await sendWa(sender, `Tahap 2/3: 📋 Mohon berikan *Deskripsi Keluhan* secara detail (lokasi, kapan terjadi, rincian masalah, dll).`)
      return new Response(JSON.stringify({ status: 'asked_deskripsi' }), { headers: { 'Content-Type': 'application/json' } })
    }

    // ── STATE: awaiting_deskripsi ─────────────────
    if (currentState === 'awaiting_deskripsi') {
      await upsertSession(supabase, {
        phone_number: sender,
        state: 'awaiting_foto',
        deskripsi: rawMessage,
      })
      await sendWa(sender, `Tahap 3/3: 📸 Silakan unggah *Bukti Visual* (Foto / Screenshot).\n\nJika tidak ada foto, ketik *LEWATI*.`)
      return new Response(JSON.stringify({ status: 'asked_foto' }), { headers: { 'Content-Type': 'application/json' } })
    }

    // ── STATE: awaiting_foto ─────────────────
    if (currentState === 'awaiting_foto') {
      let fotoUrl = null
      if (attachment) {
        fotoUrl = attachment // from Fonnte payload if it's an image
      } else if (rawMessage.toUpperCase() !== 'LEWATI') {
         // Wait for user to either send image or type lewati
         await sendWa(sender, `⚠️ Harap unggah Foto atau ketik *LEWATI*.`)
         return new Response(JSON.stringify({ status: 'waiting_foto' }), { headers: { 'Content-Type': 'application/json' } })
      }

      const ticketCode = await createTicket(
        supabase,
        profile,
        session!.satker!,
        session!.judul!,
        session!.deskripsi!,
        fotoUrl
      )

      await clearSession(supabase, sender)

      await sendWa(
        sender,
        `✅ *Laporan Anda telah berhasil direkam!*\n\n` +
        `📋 *Nomor Tiket:* ${ticketCode}\n` +
        `🛠️ *Tujuan:* ${session!.satker}\n` +
        `📝 *Judul:* ${session!.judul}\n\n` +
        `Tim *Leader* kami akan meninjau (Triage) laporan ini sebelum ditugaskan ke Eksekutor.\n` +
        `Ketik *CEK ${ticketCode}* kapan saja untuk memantau status.\n\nTerima kasih! 🙏`
      )

      return new Response(JSON.stringify({ success: true, ticket_code: ticketCode }), { headers: { 'Content-Type': 'application/json' } })
    }

    // ── STATE: awaiting_faq ─────────────────
    if (currentState === 'awaiting_faq') {
      await clearSession(supabase, sender)
      await sendWa(sender, `Informasi lebih lanjut hubungi tim IT. \n_Ketik *mulai* untuk kembali._`)
      return new Response(JSON.stringify({ status: 'sent_faq_answer' }), { headers: { 'Content-Type': 'application/json' } })
    }

    return new Response(JSON.stringify({ status: 'unhandled_state' }), { headers: { 'Content-Type': 'application/json' } })

  } catch (error) {
    console.error(error)
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : String(error) }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
