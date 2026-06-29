const supabaseUrl = process.env.SUPABASE_URL || 'https://fbgziyguyhlpadqtokjv.supabase.co'

async function test() {
  const response = await fetch(`${supabaseUrl}/functions/v1/fonnte-send`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      type: 'UPDATE',
      old_record: { status: 'open' },
      record: {
        status: 'resolved',
        source: 'whatsapp',
        phone_number: '085371020206', // The user's number from the recent webhook payload
        ticket_code: 'TKT-TEST-REAL',
        reporter_name: 'Llinneryss',
        resolution_note: 'This is a test resolution'
      }
    })
  })

  const text = await response.text()
  console.log('Status:', response.status)
  console.log('Response:', text)
}

test()
