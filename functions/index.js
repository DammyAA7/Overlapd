const functions = require("firebase-functions");
const stripe = require('stripe')('sk_test_51OWmrwIaruu0MDtuTh7GPThpzMdCA8h1Fldtd5HVnS5nPyjUdmUYuMV5kf7gQGNV1FwWMo1DCdFHo3lt45c1UjYv00vqvpo7zr', {
  apiVersion: '2023-10-16',
});
const endpointSecretAccount = 'whsec_acOhx1XWucP3CYTq91fq3ceo85XIMNLo';
const endpointSecretConnect = 'whsec_uLQlKHhvyKqpS63GU998YGytRNNtKpJI';
const admin = require('firebase-admin');
admin.initializeApp();

exports.StripePaymentIntent = functions.https.onRequest(async(req, res) =>{
    let customerId;

    const customerList = await stripe.customers.list({
        email: req.body.email,
        limit: 1,
    });
    const serviceCharge = Math.min(Math.ceil(parseInt(req.body.amount) * 0.11), 329);

    if (customerList.data.length !== 0){
        customerId = customerList.data[0].id;
    }else{
        const customer = await stripe.customers.create({
            email: req.body.email
        });
        customerId = customer.data.id;
    }
    const ephemeralKey = await stripe.ephemeralKeys.create(
      {customer: customerId},
      {apiVersion: '2023-10-16'}
    );
    const paymentIntent = await stripe.paymentIntents.create({
      customer: customerId,
      amount: parseInt(req.body.amount) + parseInt(req.body.deliveryFee) + serviceCharge,
      currency: 'eur',
      capture_method: 'manual',
      automatic_payment_methods: {
        enabled: true,
      },
      transfer_group: 'order'
    }, function (error, paymentIntent){
        if(error !=null){
            res.json({"error":error});
        }else{
            res.json({
                id: paymentIntent.id,
                paymentIntent: paymentIntent.client_secret,
                status: paymentIntent.status,
                amount: req.body.amount,
                currency: 'eur',
                ephemeralKey: ephemeralKey.secret,
                customer: customerId,
                publishableKey: 'pk_test_51OWmrwIaruu0MDtu9f0fOLYUdaDsxU6FHsV2TtXLw6CstWMCKPwZhhldZEWSmsStYY TYpfeRfzGVAZ9tfLKODOYt00gDUZP4EI',
                status: paymentIntent.status
            });
        }
    });
});

exports.StripeCapturePaymentIntent = functions.https.onRequest(async(req, res) =>{
    try {
                const intent = await stripe.paymentIntents.capture(req.body.id, {
                  amount_to_capture: req.body.amount_to_capture,
                });

                res.json({
                    success: true,
                    latest_charge: intent.latest_charge
                });
        } catch (error) {
                console.error("Error capturing payment:", error);
                res.status(500).json({ success: false, error: error.message });
            }
});



exports.StripeCreateTransfer = functions.https.onRequest(async(req, res) =>{
    try {
            const transfer = await stripe.transfers.create(
                {
                    amount: 549,
                    currency: 'eur',
                    destination: req.body.destination,
                    transfer_group: 'order',
                    source_transaction: req.body.source_transaction
                }
            );
            res.json({
                success: true,
            });
    } catch (error) {
            console.error("Error creating transfer:", error);
            res.status(500).json({ success: false, error: error.message });
        }
});


exports.StripeIdentity = functions.https.onRequest(async (req, res) => {
    try {
        const verificationSession = await stripe.identity.verificationSessions.create({
            type: 'document',
            options: {
                document: {
                    allowed_types: ['passport','driving_license'],
                    require_live_capture: true,
                    require_matching_selfie: true,
                }
            },
            metadata:{
                uid: req.body.uid
            }
        });

        res.json({
            id: verificationSession.id,
            url: verificationSession.url,
            status: verificationSession.status
        });
    } catch (error) {
        console.error("Error creating verification session:", error);
        res.status(500).json({
            error: "Error creating verification session",
        });
    }
});


exports.StripeCreateConnectAccount = functions.https.onRequest(async (req, res) => {
    try {
        const account = await stripe.accounts.create({
            type: 'express',
            business_type: 'individual',
            country: 'IE',
            email: req.body.email,
            capabilities: {
                card_payments: {
                    requested: true,
                },
                transfers: {
                    requested: true,
                },
            },
            default_currency: 'eur',
            business_profile:{
                mcc: '4215',
                product_description: 'Deliver items to client on deliverers existing route'
            },
            metadata: {
                email : req.body.email,
                uid: req.body.uid,
            }
        });

        res.json({
            id: account.id,
            disabled_reason: account.disabled_reason
        });
    } catch (error) {
        console.error("Error creating account session:", error);
        res.status(500).json({
            error: "Error creating account session",
        });
    }
});


exports.StripeCreateAccountLink = functions.https.onRequest(async (req, res) => {
    try {
        const accountLink = await stripe.accountLinks.create({
            account: req.body.account,
            type: 'account_onboarding',
            refresh_url:'https://google.com',
            return_url:'https://google.com',
        });

        res.json({
            url: accountLink.url,
        });
    } catch (error) {
        console.error("Error creating account link session:", error);
        res.status(500).json({
            error: "Error creating account link session",
        });
    }
});


exports.StripeCreateLoginLink = functions.https.onRequest(async (req, res) => {
    try {
        const loginLink = await stripe.accounts.createLoginLink(req.body.account);

        res.json({
            url: loginLink.url,
        });
    } catch (error) {
        console.error("Error creating login link session:", error);
        res.status(500).json({
            error: "Error creating login link session",
        });
    }
});

exports.StripeWebhookAccount = functions.https.onRequest(async (req, res) => {
      const sig = req.headers['stripe-signature'];
      const payloadData = req.rawBody;
      try {
        let event;
        try {
            event = stripe.webhooks.constructEvent(payloadData, sig, endpointSecretAccount);
          } catch (err) {
            return response.status(400).send(`Webhook Error: ${err.message}`);

          }
        const uid = event.data.object.metadata.uid;
        switch (event.type) {
            case 'identity.verification_session.canceled':
              const identityVerificationSessionCanceled = event.data.object;
              _updateStatus(uid, "canceled");
              break;
            case 'identity.verification_session.created':
              const identityVerificationSessionCreated = event.data.object;
              _updateStatus(uid, "created");
              break;
            case 'identity.verification_session.processing':
              const identityVerificationSessionProcessing = event.data.object;
              _updateStatus(uid, "processing");
              break;
            case 'identity.verification_session.requires_input':
              const identityVerificationSessionRequiresInput = event.data.object;
              _updateStatus(uid, "requires_input");
              break;
            case 'identity.verification_session.verified':
              const identityVerificationSessionVerified = event.data.object;
               _updateStatus(uid, "verified");
              break;
            case 'payment_intent.amount_capturable_updated':
              const paymentIntentAmountCapturableUpdated = event.data.object;
                  // Then define and call a function to handle the event payment_intent.amount_capturable_updated
              break;
            case 'payment_intent.canceled':
              const paymentIntentCanceled = event.data.object;
                  // Then define and call a function to handle the event payment_intent.canceled
              break;
            case 'payment_intent.created':
              const paymentIntentCreated = event.data.object;
                  // Then define and call a function to handle the event payment_intent.created
              break;
            case 'payment_intent.processing':
              const paymentIntentProcessing = event.data.object;
                  // Then define and call a function to handle the event payment_intent.processing
                  break;
            case 'payment_intent.succeeded':
              const paymentIntentSucceeded = event.data.object;
                  // Then define and call a function to handle the event payment_intent.succeeded
              break;
            case 'transfer.created':
              const transferCreated = event.data.object;
              _updateTransactionList(transferCreated);
              break;
            // ... handle other event types
            default:
              console.log(`Unhandled event type ${event.type}`);
          }
        return res.sendStatus(200);
      } catch (error) {
        return res.sendStatus(400).send(`Webhook Error: ${error.message}`);
      }
    });


exports.StripeWebhookConnect = functions.https.onRequest(async (req, res) => {
      const sig = req.headers['stripe-signature'];
      const payloadData = req.rawBody;
      try {
        let event;
        try {
            event = stripe.webhooks.constructEvent(payloadData, sig, endpointSecretConnect);
          } catch (err) {
            return response.status(400).send(`Webhook Error: ${err.message}`);

          }
        const uid = event.data.object.metadata.uid;
        switch (event.type) {
            case 'account.updated':
                  const accountUpdated = event.data.object;
                  _updateAccountStatus(uid, accountUpdated.id, accountUpdated.requirements.disabled_reason, accountUpdated.payouts_enabled, accountUpdated.capabilities.transfers, accountUpdated.capabilities.card_payments)
                  break;
            case 'balance.available':
              const balanceAvailable = event.data.object;
              // Then define and call a function to handle the event balance.available
              break;
            case 'payout.failed':
              const payoutFailed = event.data.object;
              // Then define and call a function to handle the event payout.failed
              break;
            case 'payout.paid':
              const payoutPaid = event.data.object;
              const account = event.account;
              // Then define and call a function to handle the event payout.paid
              _updatePayoutList(account, payoutPaid)
              break;
            case 'transfer.created':
              const transferCreated = event.data.object;
              _updateTransactionList(transferCreated.id, accountID, status)
              // Then define and call a function to handle the event payout.updated
              break;
            // ... handle other event types
            default:
              console.log(`Unhandled event type ${event.type}`);
          }
        return res.sendStatus(200);
      } catch (error) {
        return res.sendStatus(400).send(`Webhook Error: ${error.message}`);
      }
    });


async function _updateStatus(uid, status) {
  await admin.firestore().collection("users").doc(uid).set({'Stripe Identity Status': status}, {merge: true});
}

async function _updateTransactionList(transferId) {
  await admin.firestore().collection("stripe users").doc(transferId.destination).collection("transfers").doc(transferId.id).set({'amount': transferId.amount / 100}, {merge: true});
}

async function _updatePayoutList(accountID, payoutID) {
  await admin.firestore().collection("stripe users").doc(accountID).collection("payouts").doc(payoutID.balance_transaction).set({'amount': payoutID.amount / 100}, {merge: true});
}

async function _updateAccountStatus(uid, accountId, accountDisabled, payoutEnabled, transferActive, cardActive) {
  const account_UID = {
    'Stripe Account Id': accountId,
    'Stripe Account Disabled': accountDisabled,
    'Stripe Account Payout Enabled': payoutEnabled,
    'Stripe Account Transfers Active': transferActive,
    'Stripe Account Card Payment Active': cardActive
  };

  const account_stripe = {
      'uid': uid
    };

  await admin.firestore().collection("users").doc(uid).set(account_UID, {merge: true});
  await admin.firestore().collection("stripe users").doc(accountId).set(account_stripe, {merge: true});
}

exports.StripeAccountBalance = functions.https.onRequest(async (req, res) => {
    try {
        const balance = await stripe.balance.retrieve({
          stripeAccount: req.body.destination,
        });
        res.json({
            available: balance.available,
            pending: balance.pending
        });
    } catch (error) {
        console.error("Error getting account balance:", error);
        res.status(500).json({
            error: "Error getting account balance",
        });
    }
});

