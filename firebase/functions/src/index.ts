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

// run this every day at 01:00am
export const dailyRefillCheck = functions.pubsub.schedule("0 1 * * *").onRun(async (_) => {
    let cycles: Map<string, boolean> = new Map<string, boolean>();
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

    let updateEnvelopeAmount = (snap: firestore.DocumentSnapshot) => {
        let refillEvery: string = snap.get("refillEvery")
        if (cycles.get(refillEvery)) {
            let refillAmount: number = snap.get("refillAmount")
            let amount: number = snap.get("amount")
            let newAmount = amount + refillAmount
            let allowOverfill: boolean = snap.get("allowOverfill")
            if (newAmount > refillAmount && !allowOverfill) {
                newAmount = refillAmount
            }

            let a = {desc: "refilled", amt: refillAmount, on: new Date()};
            let activity = snap.get("activity")
            if (!activity) {
                activity = []
            }
            activity.push(a);
            snap.ref.update({"amount": newAmount, activity})
        }
    };

    db.collection("userExt").stream().on("data", (userSnap: firestore.DocumentSnapshot) => {
        db.collection(`userExt/${userSnap.id}/envelopes`).stream().on("data", updateEnvelopeAmount)
    })
    db.collection("family").stream().on("data", (familySnap: firestore.DocumentSnapshot) => {
        db.collection(`family/${familySnap.id}/envelopes`).stream().on("data", updateEnvelopeAmount)
    })
    // will this method return before these streams are done streaming??? hmmm, probably, but will that close the cloud func?
});