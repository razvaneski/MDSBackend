const mongoose = require("mongoose");

const reviewsSchema = new mongoose.Schema({
    user_id: { type: String, default: null },
    repairshop_id: { type: String, default: null },
    rating: { type: Number, default: null },
    message: { type: String, default: null },
    date: { type: Date, default: null }
});

module.exports = mongoose.model("review", reviewsSchema);