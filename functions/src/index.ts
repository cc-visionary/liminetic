import * as admin from "firebase-admin";

// Initialize the Firebase Admin SDK once for the entire application.
admin.initializeApp();

// Import the functions from their feature files.
import { onTaskCompleted } from "./features/tasks/onTaskCompleted";
import { onTransactionCreated } from "./features/financials/onTransactionCreated";

// Export the imported functions for Firebase to discover and deploy.
export {
  onTaskCompleted,
  onTransactionCreated,
};