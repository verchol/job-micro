const kefir = require('kefir');
const limit = process.env.repeat || 100;
console.log(`limit is ${limit}`);
var stream = kefir.stream(emitter => {

  let count = 0;
  emitter.emit(count);
  var intervalId = setInterval(() => {
    count++;
    if (count < limit) {
      emitter.emit(count);
    } else {
      emitter.end();
      clearInterval(intervalId);
    }
  }, 1000);
});

stream.log();
