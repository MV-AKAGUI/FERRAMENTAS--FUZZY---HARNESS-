const express = require('express');
const app = express();
const port = process.env.PORT || 3001;

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'sugoi-api', timestamp: new Date().toISOString() });
});

app.get('/', (req, res) => {
  res.json({ message: 'SUGOI Cadeia de Valor API ativa' });
});

app.listen(port, () => {
  console.log(SUGOI API listening on port );
});
