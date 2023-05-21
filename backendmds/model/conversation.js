const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema({
    user_id: { type: String, default: null },
    user_name: { type: String, default: null },
    repairshop_id: { type: String, default: null },
    repairshop_name: { type: String, default: null },
    messages: [{
        user_id: { type: String, default: null },
        message: { type: String, default: null },
        date: { type: Date, default: null }
    }]
});

module.exports = mongoose.model("conversation", conversationSchema);