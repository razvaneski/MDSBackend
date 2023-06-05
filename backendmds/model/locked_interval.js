const mongoose = require("mongoose");

const lockedIntervalSchema = new mongoose.Schema({
    repairshop_id: { type: String, default: null },
    start_date: { type: Date, default: null },
    end_date: { type: Date, default: null },
});

module.exports = mongoose.model("locked_interval", lockedIntervalSchema);