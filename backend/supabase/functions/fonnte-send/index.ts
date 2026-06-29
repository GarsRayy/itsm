import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// ── Message Templates ────────────────────────────────────────────────────────
function buildMessage(record: Record<string, unknown>, oldStatus: string): string | null {
  const name = (record.reporter_name as string) || 'Bapak/Ibu'
  const code = record.ticket_code as string
  const newStatus = record.status as string

  // resolved → send resolution notification
  if (newStatus === 'resolved' && oldStatus !== 'resolved') {
    const note = (record.resolution_note as string) || '-'
    return (
      `✅ *Tiket Anda Telah Diselesaikan!*\n\n` +
      `━━━━━━━━━━━━━━━━━━━━━\n` +
      `📋 *Kode Tiket:* ${code}\n` +
      `👤 *Pelapor:* ${name}\n` +
      `🔧 *Status:* RESOLVED ✅\n` +
      `━━━━━━━━━━━━━━━━━━━━━\n\n` +
      `📝 *Catatan Penyelesaian:*\n${note}\n\n` +
      `Jika masalah Anda belum teratasi, silakan balas pesan ini atau buat tiket baru.\n\n` +
      `Terima kasih telah menghubungi IT Helpdesk! 🙏`
    )
  }

  // in_progress → notify user that work has started
  if (newStatus === 'in_progress' && oldStatus === 'open') {
    const assignee = (record.assignee_name as string) || 'Tim IT'
    return (
      `🔄 *Update Tiket Anda*\n\n` +
      `Tiket *${code}* sedang dalam proses penanganan.\n\n` +
      `👨‍💻 *Ditangani oleh:* ${assignee}\n\n` +
      `Anda akan menerima notifikasi saat masalah telah diselesaikan.\n` +
      `Terima kasih atas kesabarannya! 🙏`
    )
  }

  // closed → final closure notification
  if (newStatus === 'closed' && oldStatus !== 'closed') {
    return (
      `🔒 *Tiket Ditutup*\n\n` +
      `Tiket *${code}* telah ditutup secara resmi.\n\n` +
      `Jika Anda membutuhkan bantuan lagi, silakan ketik *menu* untuk membuat laporan baru.\n\n` +
      `Salam, IT Helpdesk 🙏`
    )
  }

  return null
}

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ── Main Handler ─────────────────────────────────────────────────────────────
serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Support both POST (database webhook) and manual invocations
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders })
  }

  try {
    const body = await req.json()
    const { type, record, old_record } = body

    // Only process UPDATE events
    if (type !== 'UPDATE') {
      return new Response(JSON.stringify({ status: 'ignored', reason: 'not_update' }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Only send WA notifications for tickets sourced from WhatsApp
    if (record.source !== 'whatsapp' || !record.phone_number) {
      return new Response(JSON.stringify({ status: 'skipped', reason: 'not_wa_source' }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const oldStatus = old_record?.status ?? ''
    const message = buildMessage(record, oldStatus)

    if (!message) {
      return new Response(JSON.stringify({ status: 'no_notification_needed' }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const fonnteToken = Deno.env.get('FONNTE_TOKEN')
    if (!fonnteToken) {
      throw new Error('FONNTE_TOKEN not configured')
    }

    const response = await fetch('https://api.fonnte.com/send', {
      method: 'POST',
      headers: {
        'Authorization': fonnteToken,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        target: record.phone_number,
        message: message,
      }),
    })

    const result = await response.json()

    return new Response(
      JSON.stringify({ success: true, fonnte_response: result, status_change: `${oldStatus} → ${record.status}` }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : String(error) }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 },
    )
  }
})
