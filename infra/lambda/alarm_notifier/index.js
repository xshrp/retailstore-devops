const https = require('https');
const url = require('url');

exports.handler = async (event) => {
  const snsMessage = JSON.parse(event.Records[0].Sns.Message);
  const webhookUrl = process.env.WEBHOOK_URL;

  const alarmName    = snsMessage.AlarmName || 'Desconocida';
  const newState     = snsMessage.NewStateValue || 'UNKNOWN';
  const reason       = snsMessage.NewStateReason || 'Sin descripción';
  const description  = snsMessage.AlarmDescription || '';

  // Color según estado
  const color = newState === 'ALARM' ? '#ff0000'
              : newState === 'OK'    ? '#00ff00'
                                     : '#ffff00';

  const emoji = newState === 'ALARM' ? '🚨'
              : newState === 'OK'    ? '✅'
                                     : '⚠️';

  const payload = JSON.stringify({
    attachments: [{
      color,
      title: `${emoji} ${alarmName}`,
      fields: [
        { title: 'Estado',      value: newState,    short: true },
        { title: 'Descripción', value: description, short: false },
        { title: 'Motivo',      value: reason,      short: false },
      ],
      footer: 'AWS CloudWatch — retailstore',
      ts: Math.floor(Date.now() / 1000)
    }]
  });

  // POST al webhook
  const parsedUrl = url.parse(webhookUrl);
  return new Promise((resolve, reject) => {
    const req = https.request({
      hostname: parsedUrl.hostname,
      path:     parsedUrl.path,
      method:   'POST',
      headers:  { 'Content-Type': 'application/json' }
    }, (res) => {
      resolve({ statusCode: res.statusCode });
    });
    req.on('error', reject);
    req.write(payload);
    req.end();
  });
};