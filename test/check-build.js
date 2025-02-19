var fs = require('fs');
var path = require('path');

var recipesDir = path.join(process.cwd(), 'recipes');

function endsWith(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

function checkFiles(recipe) {
    var fullPath = path.join(recipe.path, recipe.name);
    fs.exists(fullPath, function(exists) {
        if (!exists) {
            throw ('File does not exist: ' + fullPath);
        }
    });
}

fs.readdir(recipesDir, function(err, files) {
    if (err) {
        console.error('Error reading recipes directory');
        throw err;
    }

    files.filter(function(file) {
        return endsWith(file, '.json');
    }).forEach(function(file) {
        fs.readFile(path.join(recipesDir, file), 'utf8', function(err, data) {
            if (err) {
                console.log('Error reading recipe file:', err);
                return;
            }

            try {
                var recipe = JSON.parse(data);
                checkFiles(recipe);
            } catch (parseErr) {
                console.error('Error parsing JSON in recipe file:');
                throw parseErr;
            }
        });
    });
});
