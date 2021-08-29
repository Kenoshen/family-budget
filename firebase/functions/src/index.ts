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

    let updateEnvelopeAmount = (snap: firestore.DocumentSnapshot): Promise<any> => {
        let refillEvery: string = snap.get("refillEvery")
        if (cycles.get(refillEvery)) {
            let refillAmount: number = snap.get("refillAmount")
            let amount: number = snap.get("amount")
            let newAmount = amount + refillAmount
            let allowOverfill: boolean = snap.get("allowOverfill")
            if (newAmount > refillAmount && !allowOverfill) {
                newAmount = refillAmount
            }

            let a = {desc: "refilled", amt: refillAmount, on: new Date().toISOString()};
            let activity = snap.get("activity")
            if (!activity) {
                activity = []
            }
            activity.push(a);
            return snap.ref.update({"amount": newAmount, activity})
        }
        return Promise.resolve();
    };

    let [userExt, family] = await Promise.all([db.collection("userExt").get(), db.collection("family").get()])
    let docs = []
    docs.push(...userExt.docs)
    docs.push(...family.docs)
    return Promise.all([...docs.map((d) => updateEnvelopeAmount(d))])
});