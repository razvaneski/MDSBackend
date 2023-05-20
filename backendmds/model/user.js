const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  first_name: { type: String, default: null },
  last_name: { type: String, default: null },
  username: { type: String, unique: true },
  password: { type: String },
  user_type: { type: String, default: "user" }, // can be user or repairshop
  token: { type: String },

  // repairshop fields
  repairshop_name: { type: String, default: null },
  repairshop_address: { type: String, default: null },
  repairshop_phone: { type: String, default: null },
  repairshop_email: { type: String, default: null },
  repairshop_website: { type: String, default: null }
});

module.exports = mongoose.model("user", userSchema);