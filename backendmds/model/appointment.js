const mongoose = require("mongoose");

const appointmentSchema = new mongoose.Schema({
    vehicle_id: { type: String, default: null },
    repairshop_id: { type: String, default: null },
    appointment_date: { type: Date, default: null }, // iso date string
    appointment_status: { type: String, default: "pending" }, // can be pending, confirmed, declined or completed
    user_id: { type: String, default: null }
});

module.exports = mongoose.model("appointment", appointmentSchema);