const mongoose = require("mongoose");

const vehicleSchema = new mongoose.Schema({
    make: { type: String, default: null },
    model: { type: String, default: null },
    year: { type: String, default: null },
    vin: { type: String, default: null },
    license_plate: { type: String, default: null },
    user_id: { type: String, default: null },
});

module.exports = mongoose.model("vehicle", vehicleSchema);