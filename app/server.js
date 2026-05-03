const express = require("express");
const app = express();

app.use(express.static("public"));

app.get("/health", (req, res) => res.send("OK"));

app.listen(3000, () => console.log("App running on port 3000"));