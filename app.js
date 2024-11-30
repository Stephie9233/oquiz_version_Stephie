import "dotenv/config";

import express from "express";
import session from "express-session";

import { router } from "./app/router.js";

const app = express();

// Configure le view engine
app.set("view engine", "ejs"); // => pour préciser quel view engine on utilise
app.set("views", "./app/views"); // => pour préciser à EJS dans quel dossier trouver les fichiers .ejs lors des res.render()

// Configure le dossier public
app.use(express.static("./public"));

app.use(express.urlencoded({ extended: true }));

app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: true,
  cookie: {
    secure: false,
  }
}));

app.use((req, res, next) => {
  console.log(req.session);
  
  res.locals.session = req.session;
  next();
});
// Configurer l'application
app.use(router);

app.use((req, res, next) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  next();
});




// Lancement du serveur
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server started on http://localhost:${PORT}`);
});

