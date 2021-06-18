/**
 * Background Cloud Function to be triggered by Pub/Sub.
 * This function is exported by index.js, and executed when
 * the trigger topic receives a message.
 * from https://cloud.google.com/functions/docs/calling/pubsub#functions_calling_pubsub-nodejs
 *
 * @param {object} message The Pub/Sub message.
 * @param {object} context The event metadata.
 */
 exports.greetFromPubSub = (message, context) => {
  const name = message.data
    ? Buffer.from(message.data, 'base64').toString()
    : 'empty';

  console.log(`Hello I am google-cloud-function-with-terraform, message was: ${name}!`);
};