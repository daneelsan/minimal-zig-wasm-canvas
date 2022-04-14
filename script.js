var memory = new WebAssembly.Memory({
    initial: 2 /* pages */,
    maximum: 2 /* pages */,
});

var importObject = {
    env: {
        consoleLog: (arg) => console.log(arg), // Useful for debugging on zig's side
        memory: memory,
    },
};

WebAssembly.instantiateStreaming(fetch("checkerboard.wasm"), importObject).then((result) => {
    const wasmMemoryArray = new Uint8Array(memory.buffer);

    const canvas = document.getElementById("checkerboard");
    const context = canvas.getContext("2d");
    const imageData = context.createImageData(canvas.width, canvas.height);
    context.clearRect(0, 0, canvas.width, canvas.height);

    const getDarkValue = () => {
        return Math.floor(Math.random() * 100);
    };
    const getLightValue = () => {
        return Math.floor(Math.random() * 127) + 127;
    };

    const drawCheckerboard = () => {
        const checkerBoardSize = 8;

        result.instance.exports.colorCheckerboard(
            getDarkValue(),
            getDarkValue(),
            getDarkValue(),
            getLightValue(),
            getLightValue(),
            getLightValue()
        );

        const bufferOffset = result.instance.exports.getCheckerboardBufferPointer();
        const imageDataArray = wasmMemoryArray.slice(
            bufferOffset,
            bufferOffset + checkerBoardSize * checkerBoardSize * 4
        );
        imageData.data.set(imageDataArray);

        context.clearRect(0, 0, canvas.width, canvas.height);
        context.putImageData(imageData, 0, 0);
    };

    drawCheckerboard();
    console.log(memory.buffer);
    setInterval(() => {
        drawCheckerboard();
    }, 250);
});
