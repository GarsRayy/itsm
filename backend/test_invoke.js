

const supabaseUrl = process.env.SUPABASE_URL || 'https://fbgziyguyhlpadqtokjv.supabase.co'
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'dummy_key' // We only need the URL to call functions

async function test() {
  const token = 'fonnte_token_here' // We don't need token here, edge function has it
  
  // We can just call it via HTTP
  const response = await fetch(`${supabaseUrl}/functions/v1/fonnte-send`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      // 'Authorization': `Bearer ${supabaseKey}` // Not needed if function doesn't verify JWT
    },
    body: JSON.stringify({
      type: 'UPDATE',
      old_record: { status: 'open' },
      record: {
        status: 'resolved',
        source: 'whatsapp',
        phone_number: '62895423021051',
        ticket_code: 'TKT-TEST',
        reporter_name: 'Llinneryss',
        resolution_note: 'Tested from script'
      }
    })
  })

  const text = await response.text()
  console.log('Status:', response.status)
  console.log('Response:', text)
}

test()
