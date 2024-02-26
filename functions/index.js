const functions = require("firebase-functions");
const stripe = require('stripe')('sk_test_51OWmrwIaruu0MDtuTh7GPThpzMdCA8h1Fldtd5HVnS5nPyjUdmUYuMV5kf7gQGNV1FwWMo1DCdFHo3lt45c1UjYv00vqvpo7zr');
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
      transfer_data:{
        amount: 549,
        destination: 'acct_1OoCT4RCKHyiLr0F'
      }
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
                publishableKey: 'pk_test_51OWmrwIaruu0MDtu9f0fOLYUdaDsxU6FHsV2TtXLw6CstWMCKPwZhhldZEWSmsStYYTYpfeRfzGVAZ9tfLKODOYt00gDUZP4EI',
                status: paymentIntent.status
            });
        }
    });
});


exports.StripeUpdatePaymentIntent = functions.https.onRequest(async(req, res) =>{
    const paymentIntent = await stripe.paymentIntents.update(
    req.body.id,
    {
      transfer_data:{
        destination: req.body.destination
      }
    });
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
                  console.log(`${accountUpdated}`);
                  _updateAccountStatus(uid, accountUpdated.requirements.disabled_reason, accountUpdated.payouts_enabled, accountUpdated.capabilities.transfers, accountUpdated.capabilities.card_payments)
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
              // Then define and call a function to handle the event payout.paid
              break;
            case 'payout.updated':
              const payoutUpdated = event.data.object;
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

async function _updateAccountStatus(uid, accountDisabled, payoutEnabled, transferActive, cardActive) {
  const updates = {
    'Stripe Account Disabled': accountDisabled,
    'Stripe Account Payout Enabled': payoutEnabled,
    'Stripe Account Transfers Active': transferActive,
    'Stripe Account Card Payment Active': cardActive
  };

  await admin.firestore().collection("users").doc(uid).set(updates, {merge: true});
}

exports.StripeAccountBalance = functions.https.onRequest(async (req, res) => {
    try {
        const balance = await stripe.balance.retrieve({
          stripeAccount: 'acct_1OYD9AIejXw0Dd0j',
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


