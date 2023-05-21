const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema({
    user_id: { type: String, default: null },
    repairshop_id: { type: String, default: null },
    messages: [{
        message: { type: String, default: null },
        date: { type: Date, default: null }
    }]
});

module.exports = mongoose.model("conversation", conversationSchema);