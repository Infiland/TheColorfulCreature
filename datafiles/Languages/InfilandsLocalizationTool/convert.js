window.onload = function () {
    document.getElementById('myfile').onchange = readFile;
};

function readFile() {
    // Read file
    file = this.files[0];                                                                                              
    var fReader = new FileReader();

    fReader.onload = function (event) {

        document.getElementById('fileContent').value = event.target.result;

    };

    fReader.readAsText(file);
    console.log( "The file is loaded." );

}

function convert() {
    //Initialize
    document.getElementById('result').innerHTML = "";                                   

    var file = document.getElementById('fileContent').value; //Load from textarea
    var fileNum = parseInt(document.getElementById('fileNum').value); //Load the id number

    const itemArray = file.split(/^/gm);
    const newArray = [];

    for (var i = 0; i < itemArray.length; i++) {

        newArray.push(`${i+fileNum}=${itemArray[i]}`); //Generate new text

    }

    document.getElementById('result').innerHTML = newArray.join('<br />');
    document.getElementById('memo').innerHTML = 'Texts are copied to your clipboard! Return to <a href = "https://docs.google.com/spreadsheets/d/1sO2gPX9AtXJVg1b7byPOB_xi-h8dwmZt5X0aZ08_LOo/edit">Google sheets</a> to paste it!';

    navigator.clipboard.writeText(newArray.join('')); //Copy to clipboard

}