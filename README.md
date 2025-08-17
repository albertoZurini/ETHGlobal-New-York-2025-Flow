# ETHGlobal New York - TollBooth Flow

This repository contains the **Flow callback scheduler** for the TollBooth project. The scheduler creates a subscription to access content protected by HTTP 402 screens.

-----

## Getting Started

First, navigate to the `scheduledcallbacks-scaffold` folder.

1.  **Start the Flow emulator:**

    ```
    flow emulator --scheduled-callbacks --block-time 1s
    ```

2.  **Deploy the contracts:**

    ```
    flow project deploy --network emulator
    ```

3.  **Initialize handler capabilities:**

    ```
    flow transactions send cadence/transactions/TollBooth_InitTollBoothLoopCallbackHandler.cdc \
      --network emulator \
      --signer emulator-account
    ```

4.  **Start the scheduler:**

    ```
    flow transactions send cadence/transactions/ScheduleIncrementInLoop.cdc \
      --network emulator \
      --signer emulator-account \
      --args-json '[
        {"type":"UFix64","value":"2.0"},      
        {"type":"UInt8","value":"1"},        
        {"type":"UInt64","value":"1000"},     
        {"type":"Optional","value":null}
      ]'
    ```

5.  **Check initial balances:**

    ```
    flow scripts execute cadence/scripts/GetBalances.cdc --network emulator
    ```

    *Expected output:* `100 0`

6.  **Check last transaction time:**

    ```
    flow scripts execute cadence/scripts/GetLastTransactionTime.cdc --network emulator
    ```

    *Expected output:* `nil`

7.  **Allow spending:**

    ```
    flow transactions send cadence/transactions/TollBooth_AllowTransfer.cdc \
      --network emulator \
      --signer emulator-account
    ```

8.  **Check balances again:**

    ```
    flow scripts execute cadence/scripts/GetBalances.cdc --network emulator
    ```

    *Expected output:* `a value <100` and `a value >0`

9.  **Verify transaction time:**

    ```
    flow scripts execute cadence/scripts/GetLastTransactionTime.cdc --network emulator
    ```

    *Expected output:* `a UNIX timestamp`

-----

## Running the Backend

Navigate to the `nodejs` folder and run the backend server.

1.  **Start the server:**

    ```
    node app.js
    ```

2.  **Access the content:** When you try to access the root URL (`/`), the content will only be returned if a payment has been completed **within the past 30 seconds**.

-----

## Missing Information

The current README is functional, but a few key pieces of information could improve it for a wider audience:

  * **Project Overview:** A brief, high-level explanation of what the TollBooth project does is missing. What is the overall goal?
  * **Purpose of the Arguments:** The arguments in the `ScheduleIncrementInLoop` transaction are not explained. What does `2.0`, `1`, and `1000` represent?
  * **Dependency List:** There is no mention of what software needs to be installed to run this project (e.g., Node.js, Flow CLI, etc.).
  * **Backend Logic:** A simple explanation of how the backend `app.js` file interacts with the Flow network would be helpful. For example, does it call a Flow script to check the last transaction time?
  * **What to Expect:** The README describes the commands and their outputs, but a visual or descriptive explanation of the "HTTP 402 screen" would clarify the user experience.