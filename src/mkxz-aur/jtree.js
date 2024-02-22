const fs = require('fs');
const path = require('path');
const os = require('os');

// Function to get file or directory info
function getFileStats(filePath) {
    const stats = fs.statSync(filePath);
    return {
        type: stats.isDirectory() ? 'directory' : 'file',
        name: path.basename(filePath),
        path: filePath,
        permissions: `0${(stats.mode & parseInt('777', 8)).toString(8)}`, // Convert mode to octal string
        owner: stats.uid,
        group: stats.gid,
        size: stats.size,
        modified: stats.mtime.toISOString()
    };
}

// Recursive function to build directory tree
function dirToJson(dirPath) {
    const contents = fs.readdirSync(dirPath);
    return contents.map(child => {
        const childPath = path.join(dirPath, child);
        const fileInfo = getFileStats(childPath);

        if (fileInfo.type === 'directory') {
            fileInfo.contents = dirToJson(childPath); // Recurse into subdirectory
        }

        return fileInfo;
    });
}

// Check command-line arguments
if (process.argv.length !== 3) {
    console.log('Usage: node jtree.js <directory>');
    process.exit();
}

const rootDir = path.resolve(process.argv[2]);
const jsonTree = {
    type: 'directory',
    name: path.basename(rootDir),
    path: rootDir,
    contents: dirToJson(rootDir)
};

// Функция форматирования даты/времени
function formatDateTime(date) {
    const pad = (s) => (s < 10 ? '0' + s : s);
    return (
        `${pad(date.getDate())}-${pad(date.getMonth() + 1)}-${date.getFullYear()}` +
        `-${pad(date.getHours())}-${pad(date.getMinutes())}-${pad(date.getSeconds())}`
    );
}

// Генерация имени файла с учетом имени директории и текущего времени
const dateTimeSuffix = formatDateTime(new Date());
const outputFileName = `${path.basename(rootDir)}-${dateTimeSuffix}.json`;

// Путь к директории ~/archives
const archivesDir = path.join(os.homedir(), 'archives');

// Создание директории, если её нет
if (!fs.existsSync(archivesDir)) {
    fs.mkdirSync(archivesDir);
}

// Сохранение JSON-файла в директорию ~/archives
const outputFilePath = path.join(archivesDir, outputFileName);
fs.writeFileSync(outputFilePath, JSON.stringify(jsonTree));

console.log(`Minified directory tree of ${rootDir} has been saved to ${outputFilePath}`); // Используйте rootDir здесь
