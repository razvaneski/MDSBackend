require("dotenv").config();
require("./config/database").connect();
const express = require("express");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const app = express();

app.use(express.json());

const User = require("./model/user");
const Vehicle = require("./model/vehicle");
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
      const { first_name, last_name, username, password } = req.body;
  
      // Validate user input
      if (!(username && password && first_name && last_name)) {
        res.status(400).send("All input is required");
      }
  
      // check if user already exist
      // Validate if user exist in our database
      const oldUser = await User.findOne({ username });
  
      if (oldUser) {
        return res.status(409).send("User Already Exist. Please Login");
      }
  
      //Encrypt user password
      encryptedPassword = await bcrypt.hash(password, 10);
  
      // Create user in our database
      const user = await User.create({
        first_name,
        last_name,
        username: username.toLowerCase(), // sanitize: convert username to lowercase
        password: encryptedPassword,
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
        res.status(400).send("All input is required");
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
      res.status(400).send("Invalid Credentials");
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
      res.status(400).send("Invalid token");
    }
    else if (user.token !== token) {
      console.log("token mismatch");
      // console.log(user.token);
      // console.log(token);
      res.status(400).send("Invalid token");
    } else {
      console.log("token match");
      res.status(200).json(user);
    }

  } catch (error) {
    console.log("invalid token");
    res.status(400).send("Invalid token");
  }
});

app.post("/logout", async (req, res) => {
  const { token } = req.headers;
  try {
    const decoded = jwt.verify(token, process.env.TOKEN_KEY);
    const userId = decoded.user_id;

    const user = await User.findById(userId);
    if (!user) {
      res.status(400).send("Invalid token");
    } else {
      user.token = null;
      await user.save();
      res.status(200).send("Logout successful");
    }
  } catch {
    res.status(400).send("Invalid token");
  }
});

app.post("/addvehicle", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(400).send("Invalid token");
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
    res.status(400).send("Invalid token");
  } else {
    const vehicles = await Vehicle.find({ user_id: userId });
    res.status(200).json(vehicles);
  }
});

app.get("/getvehicle/", async (req, res) => {
  const { token } = req.headers;
  const { id } = req.query;
  const userId = getUserIdFromToken(token);
  if (!userId) {
    res.status(400).send("Invalid token");
  } else {
    const vehicle = await Vehicle.findById(id);
    if (!vehicle) {
      res.status(400).send("No vehicle found");
    } else {
      if (vehicle.user_id === userId) {
        res.status(200).json(vehicle);
      } else {
        res.status(400).send("Invalid token");
      }
    }
  }
});

app.post("/updatevehicle", async (req, res) => {
  const { token } = req.headers;
  const userId = getUserIdFromToken(token);
  const { id } = req.query;
  if (!userId) {
    res.status(400).send("Invalid token");
  } else {
    const vehicle = await Vehicle.findById(id);
    if (!vehicle) {
      res.status(400).send("No vehicle found");
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
        res.status(400).send("Invalid token");
      }
    }
  }
});

module.exports = app;