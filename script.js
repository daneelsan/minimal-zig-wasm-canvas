var memory = new WebAssembly.Memory({
    // See build.zig for reasoning
    initial: 2 /* pages */,
    maximum: 2 /* pages */,
});

var importObject = {
    env: {
        consoleLog: (arg) => console.log(arg), // Useful for debugging on zig's side
        memory: memory,
    },
};

WebAssembly.instantiateStreaming(fetch("zig-out/bin/checkerboard.wasm"), importObject).then((result) => {
    const wasmMemoryArray = new Uint8Array(memory.buffer);


    // Automatically set canvas size as defined in `checkerboard.zig`
    const checkerboardSize = result.instance.exports.getCheckerboardSize();
    const canvas = document.getElementById("checkerboard");
    canvas.width = checkerboardSize;
    canvas.height = checkerboardSize;

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
            bufferOffset + checkerboardSize * checkerboardSize * 4
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
