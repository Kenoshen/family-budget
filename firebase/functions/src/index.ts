import * as functions from "firebase-functions";
import {firestore} from "firebase-admin";


const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// const RefillEveryNever = "never"
const RefillEveryDay = "day"
const RefillEveryWeek = "week"
const RefillEveryMonth = "month"
const RefillEveryYear = "year"

// run this every day at 0:00 GMT
export const dailyRefillCheck = functions.pubsub.schedule("0 0 * * *").onRun((_) => {
    let cycles:Map<string, boolean> = new Map<string, boolean>();
    cycles.set(RefillEveryDay, true);
    let now = new Date();
    if (now.getDay() === 1) { // every monday
        cycles.set(RefillEveryWeek, true)
    }
    if (now.getDate() == 1) { // every 1st of the month
        cycles.set(RefillEveryMonth, true)
        if (now.getMonth() == 0) { // every Jan 1st of the year
            cycles.set(RefillEveryYear, true)
        }
    }

    db.collection("envelope").stream().on("data", (snap: firestore.DocumentSnapshot) => {
        let refillEvery:string = snap.get("refillEvery")
        if (cycles.get(refillEvery)) {
            let refillAmount:number = snap.get("refillAmount")
            let amount:number = snap.get("amount")
            let newAmount = amount + refillAmount
            let allowOverfill:boolean = snap.get("allowOverfill")
            if (newAmount > refillAmount && !allowOverfill) {
                newAmount = refillAmount
            }
            // is there a way to do batch updates here so we don't just blast out an update call for each row?
            snap.ref.update({"amount": newAmount})
        }
    })
});