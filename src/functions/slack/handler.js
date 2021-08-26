const https = require("https");

exports.lambda_handler = (event, context, callback) => {
  const payload = JSON.stringify({
    text: `${event.message} ${
      event.inputs && event.inputs.length > 0 ? event.inputs.join(" ") : ""
    }`
  });

  const options = {
    hostname: "hooks.slack.com",
    method: "POST",
    path: "/services/T0UKUKNBV/BFSSRMUHJ/4cDo5CT9cOlLVQkPkMQeiDtZ"
  }

  const req = https.request(options, res =>
    res.on("data", () => callback(null, "OK"))
  );
  req.on("error", error => callback(JSON.stringify(error)));
  req.write(payload);
  req.end();
};
