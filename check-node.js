// Простая проверка Node.js перед установкой зависимостей
// Этот файл используется в preinstall скрипте

try {
  const nodeVersion = process.version;
  const majorVersion = parseInt(nodeVersion.slice(1).split('.')[0]);
  
  if (majorVersion < 18) {
    console.error('');
    console.error('❌ Ошибка: Требуется Node.js версии 18 или выше');
    console.error(`   Текущая версия: ${nodeVersion}`);
    console.error('');
    console.error('Установите Node.js:');
    console.error('  1. Запустите: npm run install-node');
    console.error('  2. Или скачайте с https://nodejs.org/');
    console.error('');
    process.exit(1);
  }
  
  console.log(`✓ Node.js ${nodeVersion} - OK`);
} catch (error) {
  console.error('❌ Ошибка при проверке Node.js:', error.message);
  console.error('');
  console.error('Установите Node.js:');
  console.error('  1. Запустите: npm run install-node');
  console.error('  2. Или скачайте с https://nodejs.org/');
  console.error('');
  process.exit(1);
}





