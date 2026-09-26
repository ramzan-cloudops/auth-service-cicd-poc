const express = require("express");

const app = express();

const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.json({
    service: "auth-service",
    status: "running"
  });
});

app.get("/health", (req, res) => {
  res.json({
    status: "healthy"
  });
});

app.listen(PORT, () => {
  console.log(`Auth service running on port ${PORT}`);
});  



