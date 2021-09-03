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

// run this every day at 01:00am (central)
export const dailyRefillCheck = functions.pubsub.schedule("0 1 * * *").onRun(async (_) => {
    let now = new Date();
    console.log(`Do daily refill check at ${now.toISOString()} day: ${now.getDay()} date: ${now.getDate()} month: ${now.getMonth()}`)
    let cycles: { [key: string]: boolean } = {};
    cycles[RefillEveryDay] = true;
    if (now.getDay() === 1) { // every monday
        cycles[RefillEveryWeek] = true
    }
    if (now.getDate() == 1) { // every 1st of the month
        cycles[RefillEveryMonth] = true
        if (now.getMonth() == 0) { // every Jan 1st of the year
            cycles[RefillEveryYear] = true
        }
    }
    console.log(`Cycles: ${JSON.stringify(cycles)}`)
    let updatedEnvelopes: string[] = []

    let getEnvelopes = async (snap: firestore.DocumentSnapshot): Promise<firestore.DocumentSnapshot[]> => {
        let envelopes = await db.collection(snap.ref.path + "/envelopes").get()
        return envelopes.docs
    }

    let updateEnvelopeAmount = async (snap: firestore.DocumentSnapshot): Promise<any> => {
        let path = snap.ref.path
        try {
            let data = snap.data()
            if (data) {
                let refillEvery: string = data.refillEvery
                if (cycles[refillEvery]) {
                    let refillAmount: number = data.refillAmount
                    let amount: number = data.amount
                    let newAmount = amount + refillAmount
                    let allowOverfill: boolean = data.allowOverfill
                    if (newAmount > refillAmount && !allowOverfill) {
                        newAmount = refillAmount
                    }

                    let a = {desc: "refilled", amt: refillAmount, on: now.toISOString()};
                    let activity = data.activity
                    if (!activity) {
                        activity = []
                    }
                    activity.push(a);
                    updatedEnvelopes.push(path)
                    await snap.ref.update({"amount": newAmount, activity})
                } else {
                    console.log(`cycles[${refillEvery}] === false for ${path}`)
                }
            } else {
                console.log(`snapshot data was undefined for ${path}`)
            }
        } catch (e) {
            console.log(`error for ${path}: ${e}`)
        }
    };

    console.log("Searching for userExt and family envelopes...")
    let [userExt, family] = await Promise.all([db.collection("userExt").get(), db.collection("family").get()])
    console.log(`Found ${userExt.docs.length} userExt elements and ${family.docs.length} family elements`)
    let envelopes = await Promise.all([...userExt.docs, ...family.docs].map((s) => getEnvelopes(s))).then((docsOfDocs) => {
        let combinedDocs: firestore.DocumentSnapshot[] = []
        docsOfDocs.forEach((docs) => combinedDocs.push(...docs))
        return combinedDocs
    })
    console.log(`Updating a total of ${envelopes.length} envelopes`)
    await Promise.all(envelopes.map((d) => updateEnvelopeAmount(d)))
    console.log(`Finished updating ${updatedEnvelopes.length} envelopes`)
    console.log(`Envelope ids: [${updatedEnvelopes.join(", ")}]`)
});