import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { setGlobalOptions } from "firebase-functions/v2/options";

setGlobalOptions({ region: "europe-west3" });
admin.initializeApp();

export const onPinCreated = functions.firestore.onDocumentCreated(
  "walls/{wallId}/pins/{pinId}",
  async (event) => {
    const wallId = event.params.wallId;
    const snap = event.data;

    // Wall-Dokument abrufen
    const wallDoc = await admin
      .firestore()
      .collection("walls")
      .doc(wallId)
      .get();

    const wallData = wallDoc.data();
    const wallTitle = wallData?.title || "Pinnwand";
    const pinTitle = snap?.data()?.title || "Pin";

    await admin.messaging().send({
      topic: `wall_${wallId}`,
      notification: {
        title: `Neuer Pin in "${wallTitle}"`,
        body: `"${pinTitle}" wurde zur Pinnwand hinzugefügt`,
      },
    });
  }
);
