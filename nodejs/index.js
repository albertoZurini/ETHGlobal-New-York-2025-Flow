const express = require("express");
const fcl = require("@onflow/fcl");
const fs = require("fs");
const path = require("path");

// --- Configuration ---

// Point FCL to the local emulator's access node.
fcl.config({
  "accessNode.api": "http://127.0.0.1:8888",
});

// The address of the account where the TollBooth contract is deployed.
// **IMPORTANT:** Replace this with the actual address from your emulator.
const contractAddress = "0xf8d6e0586b0a20c7"; 

// --- Express Server Setup ---
const app = express();
const port = 3030;

/**
 * Retrieves the last transfer timestamp from the Flow blockchain.
 * @returns {Promise<number | null>} The last transfer timestamp in milliseconds, or null if not set.
 */
const getLastTransferTime = async () => {
  try {
    console.log("Executing script to get the last transfer timestamp...");

    const timestamp = await fcl.query({
      cadence: `
import TollBooth from ${contractAddress}

access(all)
fun main(): UFix64? {
    return TollBooth.getLastTransferTimestamp()
}
      `,
    });

    console.log("--- Script Result ---");
    
    if (timestamp === null) {
      console.log("The last transfer timestamp is not set (it's nil).");
      return null;
    } else {
      console.log(`Raw timestamp value: ${timestamp}`);
      // The UFix64 value is returned as a string. Convert it to a number.
      const timestampAsNumber = parseFloat(timestamp);
      // JavaScript's Date object and `Date.now()` work with milliseconds.
      // The timestamp from the blockchain is in seconds, so we multiply by 1000.
      const timestampInMilliseconds = timestampAsNumber * 1000;
      const date = new Date(timestampInMilliseconds);
      console.log(`Converted to Date: ${date.toUTCString()}`);
      return timestampInMilliseconds;
    }
  } catch (error) {
    console.error("Error executing the script:", error);
    // In case of an error fetching the timestamp, we can return null
    // and let the endpoint handle it.
    return null;
  }
};

// --- API Endpoint ---

app.get("/", async (req, res) => {
  const lastTransferTimestamp = await getLastTransferTime();

  if (lastTransferTimestamp === null) {
    // If there's no timestamp, we can decide what the default behavior should be.
    // Here, we'll return a 402 as a safe default.
    return res.status(402).send("Payment Required: No transfer timestamp found.");
  }

  const now = Date.now();
  const fiveMinutesInMillis = 5 * 60 * 1000;
  const timeDifference = now - lastTransferTimestamp;

  if (timeDifference < fiveMinutesInMillis) {
    res.status(200).send("private content");
  } else {
    res.status(402).send("Payment Required");
  }
});

// --- Start the server ---

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});