require("dotenv").config();
require("./config/database").connect();
const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cron = require("node-cron");

const app = express();

app.use(express.json());

const User = require("./model/user");
const Vehicle = require("./model/vehicle");
const Appointment = require("./model/appointment");
const Conversation = require("./model/conversation");
const { json } = require("express");

function getUserIdFromToken(token) {
  try {
    const decoded = jwt.verify(token, process.env.TOKEN_KEY);
    const userId = decoded.user_id;
    return userId;
  } catch (error) {
    return null;
  }
}

// Register
app.post("/register", async (req, res) => {

    // Our register logic starts here
    try {
      // Get user input
      const { first_name, last_name, username, password, user_type } = req.body;
  
      // Validate user input
      if (!(username && password && first_name && last_name && user_type)) {
        res.status(416).send("All input is required");
      }
  
      // check if user already exist
      // Validate if user exist in our database
      const oldUser = await User.findOne({ username });
  
      if (oldUser) {
        return res.status(416).send("User already exists. Please log in.");
      }
  
      //Encrypt user password
      encryptedPassword = await bcrypt.hash(password, 10);
  
      // Create user in our database
      const user = await User.create({
        first_name,
        last_name,
        username: username.toLowerCase(), // sanitize: convert username to lowercase
        password: encryptedPassword,
        user_type: user_type.toLowerCase(),
      });
  
      // Create token
      const token = jwt.sign(
        { user_id: user._id, username },
        process.env.TOKEN_KEY,
        {
          expiresIn: "2h",
        }
      );
      // save user token
      user.token = token;

      if (user_type.toLowerCase() === "repairshop") {
        const { repairshop_name, repairshop_address, repairshop_phone, repairshop_email, repairshop_website } = req.body;
        user.repairshop_name = repairshop_name;
        user.repairshop_address = repairshop_address;
        user.repairshop_phone = repairshop_phone;
        user.repairshop_email = repairshop_email;
        user.repairshop_website = repairshop_website;
      }

      await user.save();
      // return new user
      res.status(201).json(user);
    } catch (err) {
      console.log(err);
    }
    // Our register logic ends here
});

// Login
app.post("/login", async (req, res) => {

    // Our login logic starts here
    try {
      // Get user input
      const { username, password } = req.body;
  
      // Validate user input
      if (!(username && password)) {
        res.status(416).send("All input is required");
      }
      // Validate if user exist in our database
      const user = await User.findOne({ username });
  
      if (user && (await bcrypt.compare(password, user.password))) {
        // Create token
        const token = jwt.sign(
          { user_id: user._id, username },
          process.env.TOKEN_KEY,
          {
            expiresIn: "2h",
          }
        );
  
        // save user token
        user.token = token;
        await user.save();
        // user
        res.status(200).json(user);
      }
      res.status(416).send("Invalid Credentials");
    } catch (err) {
      console.log(err);
    }
    // Our register logic ends here
});

app.get("/getuser", async (req, res) => {
  const { token } = req.headers;
  try {
    const decoded = jwt.verify(token, process.env.TOKEN_KEY);
    const userId = decoded.user_id;

    const user = await User.findById(userId);
    if (!user) {
      console.log("no user");
      res.status(416).send("Invalid token");
    }
    else if (user.token !== token) {
      console.log("token mismatch");
      // console.log(user.token);
      // console.log(token);
      res.status(416).send("Invalid token");
    } else {
      console.log("token match");
      res.status(200).json(user);
    }

  } catch (error) {
    console.log("invalid token");
    res.status(416).send("Invalid token");
  }
});

app.post("/logout", async (req, res) => {
  const { token } = req.headers;
  try {
    const decoded = jwt.verify(token, process.env.TOKEN_KEY);
    const userId = decoded.user_id;

    const user = await User.findById(userId);
    if (!user) {
      res.status(416).send("Invalid token");
    } else {
      user.token = null;
      await user.save();
      res.status(200).send("Logout successful");
    }
  } catch {
    res.status(416).send("Invalid token");
  }
});

app.post("/addvehicle", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const { make, model, year, vin, license_plate } = req.body;
    const vehicle = await Vehicle.create({
      make,
      model,
      year,
      vin,
      license_plate,
      user_id: userId,
    });
    await vehicle.save();
    res.status(201).json(vehicle);
  }
});

app.get("/getvehicles", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const vehicles = await Vehicle.find({ user_id: userId });
    res.status(200).json(vehicles);
  }
});

app.get("/getvehicle", async (req, res) => {
  const { token } = req.headers;
  const { id } = req.query;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const vehicle = await Vehicle.findById(id);
    if (!vehicle) {
      res.status(416).send("No vehicle found");
    } else {
      if (vehicle.user_id === userId) {
        res.status(200).json(vehicle);
      } else {
        res.status(416).send("Invalid token");
      }
    }
  }
});

app.post("/updatevehicle", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  const { id } = req.query;
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const vehicle = await Vehicle.findById(id);
    if (!vehicle) {
      res.status(416).send("No vehicle found");
    } else {
      if (vehicle.user_id === userId) {
        const { make, model, year, vin, license_plate } = req.body;
        vehicle.make = make;
        vehicle.model = model;
        vehicle.year = year;
        vehicle.vin = vin;
        vehicle.license_plate = license_plate;
        await vehicle.save();
        res.status(200).json(vehicle);
      } else {
        res.status(416).send("Invalid token");
      }
    }
  }
});

app.post("/deletevehicle", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  const { id } = req.query;
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const vehicle = await Vehicle.findById(id);
    if (!vehicle) {
      res.status(416).send("No vehicle found");
    } else {
      if (vehicle.user_id == userId) {
        await Vehicle.findByIdAndDelete(id);
        res.status(200).send("Vehicle deleted");
      } else {
        res.status(416).send("Invalid token");
      }
    }
  }
});

app.get("/getuserappointments", async (req, res) => { // checked
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const appointments = await Appointment.find({ user_id: userId });
    var response = [];
    // wait for all promises to resolve
    await Promise.all(appointments.map(async (appointment) => {
        response.push({
          appointment: appointment,
          vehicle: await Vehicle.findById(appointment.vehicle_id),
          repairshop: await User.findById(appointment.repairshop_id),
        });
    }));
    res.status(200).json(response);
  }
});

app.get("/getrepairshopappointments", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const appointments = (await Appointment.find({ repairshop_id: userId })).filter(appointment => appointment.status != "cancelled");
    var response = [];
    // wait for all promises to resolve
    await Promise.all(appointments.map(async (appointment) => {
        response.push({
          appointment: appointment,
          vehicle: await Vehicle.findById(appointment.vehicle_id),
          repairshop: await User.findById(appointment.repairshop_id),
        });
    }));
    res.status(200).json(response);
  }
});

app.post("/addappointment", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const { vehicle_id, repairshop_id, appointment_date } = req.body;
    // cast appointment_date to Date object
    const date = new Date(appointment_date);
    // check if date is valid
    if (date == "Invalid Date") {
      res.status(416).send("Invalid date");
    }
    const appointment = await Appointment.create({
      vehicle_id,
      repairshop_id,
      appointment_date: date,
      user_id: userId,
    });
    await appointment.save();
    res.status(201).json(appointment);
  }
});

app.post("/updateappointmentstatus", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  const { id } = req.query;
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const appointment = await Appointment.findById(id);
    if (!appointment) {
      res.status(416).send("No appointment found");
    } else {
      if (appointment.repairshop_id == userId || appointment.user_id == userId) {
        const { appointment_status } = req.body;
        appointment.appointment_status = appointment_status;
        await appointment.save();
        res.status(200).json(appointment);
      } else {
        res.status(416).send("Invalid token");
      }
    }
  }
});

app.post("/deleteappointment", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  const { id } = req.query;
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const appointment = Appointment.findById(id);
    if (!appointment) {
      res.status(416).send("No appointment found");
    } else {
      if (appointment.user_id == userId) {
        await Appointment.findByIdAndDelete(id);
        res.status(200).send("Appointment deleted");
      } else {
        res.status(416).send("Invalid token");
      }
    }
  }
});

app.get("/getrepairshops", async (req, res) => { // checked
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const repairshops = await User.find({ user_type: "repairshop" });
    res.status(200).json(repairshops);
  }
});

app.get("/getrepairshop", async (req, res) => { // checked
  const { token } = req.headers;
  const { id } = req.query;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const repairshop = await User.findById(id);
    if (!repairshop) {
      res.status(416).send("No repairshop found");
    } else {
      if (repairshop.user_type === "repairshop") {
        res.status(200).json(repairshop);
      } else {
        res.status(416).send("No repairshop found");
      }
    }
  }
});

app.get("/getconversations", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const conversations = await Conversation.find({ $or: [{ user_id: userId }, { repairshop_id: userId }] });
    res.status(200).json(conversations);
  }
});

app.get("/getconversation", async (req, res) => {
  const { token } = req.headers;
  const { receiver_id } = req.query;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const conversation = await Conversation.findOne({ $or: [{ user_id: userId, repairshop_id: receiver_id }, { user_id: receiver_id, repairshop_id: userId }] });
    if (!conversation) {
      const currentUser = await User.findById(userId);
      if (!currentUser) {
        res.status(416).send("Invalid token");
      } else {
        if (currentUser.user_type === "user") {
          const newConversation = await Conversation.create({
            user_id: userId,
            user_name: currentUser.first_name + " " + currentUser.last_name,
            repairshop_id: receiver_id,
            repairshop_name: (await User.findById(receiver_id)).repairshop_name,
            messages: [],
          });
          await newConversation.save();
          res.status(200).json(newConversation);
        } else {
          const newConversation = await Conversation.create({
            user_id: receiver_id,
            user_name: (await User.findById(receiver_id)).first_name + " " + (await User.findById(receiver_id)).last_name,
            repairshop_id: userId,
            repairshop_name: currentUser.repairshop_name,
            messages: [],
          });
          await newConversation.save();
          res.status(200).json(newConversation);
        }
      }
    } else {
      res.status(200).json(conversation);
    }
  }
});

app.post("/sendmessage", async (req, res) => {
  const { token } = req.headers;
  const { receiver_id } = req.query;
  const { message } = req.body;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const user = await User.findById(userId);
    if (!user) {
      res.status(416).send("Invalid token");
    } else {
      if (user.user_type === "user") {
        const conversation = await Conversation.findOne({ user_id: userId, repairshop_id: receiver_id });
        if (!conversation) {
          const newConversation = await Conversation.create({
            user_id: userId,
            user_name: user.first_name + " " + user.last_name,
            repairshop_id: receiver_id,
            repairshop_name: (await User.findById(receiver_id)).repairshop_name,
            messages: [{
              user_id: userId,
              message: message,
              date: new Date(),
            }],
          });
          await newConversation.save();
          res.status(200).json(newConversation);
        } else {
          conversation.messages.push({
            user_id: userId,
            message: message,
            date: new Date(),
          });
          await conversation.save();
          res.status(200).json(conversation);
        }
      } else {
        const conversation = await Conversation.findOne({ user_id: receiver_id, repairshop_id: userId });
        if (!conversation) {
          const newConversation = await Conversation.create({
            user_id: receiver_id,
            user_name: (await User.findById(receiver_id)).first_name + " " + (await User.findById(receiver_id)).last_name,
            repairshop_id: userId,
            repairshop_name: user.repairshop_name,
            messages: [{
              user_id: userId,
              message: message,
              date: new Date(),
            }],
          });
          await newConversation.save();
          res.status(200).json(newConversation);
        } else {
          conversation.messages.push({
            user_id: userId,
            message: message,
            date: new Date(),
          });
          await conversation.save();
          res.status(200).json(conversation);
        }
      }
    }
  }
});

app.get("/getreviews", async (req, res) => {
  const { token } = req.headers;
  const { repairshop_id } = req.query;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const reviews = await Review.find({ repairshop_id: repairshop_id });
    res.status(200).json(reviews);
  }
});

app.post("/addreview", async (req, res) => {
  const { token } = req.headers;
  const { repairshop_id } = req.query;
  const { rating, message } = req.body;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(416).send("Invalid token");
  } else {
    const newReview = await Review.create({
      user_id: userId,
      repairshop_id: repairshop_id,
      rating: rating,
      message: message,
      date: new Date(),
    });
    await newReview.save();
    res.status(200).json(newReview);
  }
});

const job = cron.schedule('*/15 * * * *', async () => {
  console.log("Appointments cleanup...");
  try {
    // Fetch all appointments
    const appointments = await Appointment.find({});

    // Perform action on each appointment
    appointments.forEach(async appointment => {
      // Check if the appointment date is in the past
      if (appointment.appointment_date < new Date()) {
        if (appointment.appointment_status === "pending") {
          appointment.appointment_status = "declined";
          await appointment.save();
        } else if (appointment.appointment_status === "confirmed") {
          appointment.appointment_status = "completed";
          await appointment.save();
        }
      }
    });
  } catch (error) {
    console.error('Error occurred during cron job:', error);
  }
});

job.start();
module.exports = app;