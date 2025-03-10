*Русская версия • [English version](./README.md)*

# Сценарий для конвертации курсора
Это серия скриптов, которые могут помочь вам при создании курсора для Linux. По вопросам и проблемам не стесняйтесь писать в Issues этого репозитория.

## Предыстория
Мне понравились анимированные курсоры от одного автора ([\_BLZ\_](https://ko-fi.com/blz_404/shop)), которые созданы для Windows и macOS. Я подумал, что было бы неплохо портировать их для Linux. На пути к этому я встретился с кучей проблем, для решения которых мне и пришлось написать этот скрипт. Самая главная проблема была в KDE Plasma, которая позволяла установить только 32 размер курсора.

Для решения этой задачи нужно было разобрать файл XCursor, преобразовать каждый кадр курсора в разный размер (например, если преобразовать кадр в 16 и 36 размер, то KDE Plasma даст установить 16 и 36 размер) и заново собрать в XCursor. В GIMP на это ушло бы целые часы.

## Какие задачи решают эти скрипты?
Давайте здесь кратко опишу про скрипты. Ниже будет более подробное объяснение и примеры использования.

https://github.com/user-attachments/assets/b320720b-553a-49b1-945c-e0fa10611a6f

### config.sh
Это не скрипт, его не нужно запускать. В нём хранятся параметры конфигурации для скриптов ниже.

### cursor_converting.sh
Этот скрипт выполняет операции по преобразованию:
1. Преобразование всех ANI/CUR курсоров от Windows в формат XCursor (настраивается через параметр `CONVERT_WINDOWS_CURSOR`, об этом чуть позже)
2. Распаковывает каждый XCursor файл, после чего адаптирует его для разных размеров (настраивается через `CURSOR_SIZES`. Например, 12, 18, 24, 30, 36, 42, 48, 54, 60, 66 и 72 размер, как в Breeze Cursor)
3. Снова собирает в единый XCursor файл и сохраняет в `PATH_TO_ADAPT_XCURSOR`. Вуаля, теперь KDE Plasma сможет устанавливать разный размер этим курсорам.

### cursor_install.sh
Этот скрипт собирает все XCursor файлы в единую папку и позволяет сразу установить их в систему. Для работы необходим шаблон, поверх которого и установятся новые курсоры. В качестве шаблона можно использовать практически любой пак курсоров, например, Breeze.
1. Выполняется сценарий `cursor_converting.sh` (отключается через параметр `CONVERTING`)
2. Копируется шаблон, настраивается название пака (`PACK_NAME` и `PACK_DESCRIPTION`)
3. Поверх шаблона устанавливаются XCursor файлы, которые были сформированы до этого (настраивается в `CURSOR_ACTIONS`)
4. Курсоры устанавливаются в вашу систему (`INSTALL_CURSOR_PACK`)

### clear.sh
Очищает папки `PATH_TO_ADAPT_XCURSOR` и `PATH_TO_XCURSOR`, в которых скапливается мусор после компиляции курсора.

## Зависимости
- [bc](https://git.gavinhoward.com/gavin/bc) (обязательно, требуется для математических вычислений)
- [win2xcur](https://github.com/quantum5/win2xcur) (опционально, требуется для конвертации курсоров из Windows формата)
- [xcur2png](https://github.com/eworm-de/xcur2png) (обязательно, требуется для распаковки XCursor)
- [ImageMagick](https://imagemagick.org/script/download.php) (обязательно, требуется для преобразования изображений в разное разрешение)
- xcursorgen (обязательно, требуется для упаковки XCursor)

## Настройка конфигурации (config.sh)

### Настройка путей
- `PATH_TO_ANI_CUR_CURSORS`: директория, в которой хранятся Windows курсоры
- `PATH_TO_XCURSOR`: директория, в которой будут необработанные XCursor файлы
- `PATH_TO_ADAPT_XCURSOR`: директория, в которой будут XCursor курсоры, прошедшие всю обработку скриптами
- `PATH_TO_TEMPLATE`: директория, в которой будет храниться сторонний пак с курсорами. Поверх него установятся ваши курсоры. **В директории должна быть папка "cursors"!**
- `PATH_TO_INSTALL`: директория, в которую будут установлены курсоры.

### Настройка cursor_converting.sh
- `CONVERT_WINDOWS_CURSOR`: установите значение 1, если нужно конвертировать Windows курсоры в XCursor
- `CURSOR_SIZES`: укажите размеры, в которые хотите преобразовать курсоры. Если вы используете KDE Plasma, то можете оставить значения по умолчанию.

### Настройка cursor_install.sh
- `CONVERTING`: установите значение 1, если перед этим нужно вызвать `cursor_converting.sh`
- `INSTALL_CURSOR_PACK`: установите значение 1, если курсоры нужно установить в `PATH_TO_INSTALL`
- `REINSTALL_PACK`: установите значение 1, если вы экспериментируете. Это позволит без проблем заново устанавливать курсорный пак, который вы уже собирали до этого (просто удаляя курсорный пак, сгенерированный до этого)
- `PACK_NAME`: название курсорного пака. Папка с курсорами будет называться таким же названием
- `PACK_DESCRIPTION`: описание вашего курсорного пака
- `CURSOR_ACTIONS`: по умолчанию переменная настроена на работы от [\_BLZ\_](https://ko-fi.com/blz_404/shop) автора. Слева название файла, справа указаны действия, на которые курсор реагирует. Например, файл Link будет вызываться на все ссылки, то есть pointer, hand1 и так далее.

## Пример, как работать со скриптами
1. Скачайте репозиторий:
```shell
git clone "https://github.com/Katze-942/xcursor-massive-resize" --depth=1
cd xcursor-massive-resize
```
2. Откройте `config.sh` и настройте параметры, описанные выше
3. Настройте шаблон, который будет использоваться для создания темы. Поверх этого шаблона будут наложены ваши курсоры. Я предпочитаю использовать [курсоры от Breeze](https://invent.kde.org/plasma/breeze/-/tree/master/cursors/Breeze_Light/Breeze_Light). **В шаблоне должна быть только папка "cursors"! Никаких других папок и файлов там быть не должно.**
4. Скачаем какой-нибудь курсорный пак для Windows (этот пункт можно пропустить, скопировав XCursor файлы в `PATH_TO_XCURSOR` и установив `CONVERT_WINDOWS_CURSOR=0`). В качестве примера возьмём [этот](https://ko-fi.com/s/7ddcb948b6) курсорный пак
5. Распакуйте все .ani/.cur файлы в директорию `PATH_TO_ANI_CUR_CURSORS` *(пропустите, если `CONVERT_WINDOWS_CURSOR=0`)*
6. Запустите `cursor_converting.sh`. Если всё пройдёт успешно, то в директории `PATH_TO_ADAPT_XCURSOR` появятся все ваши курсоры в формате XCursor
7. Настройте `PACK_NAME` и `PACK_DESCRIPTION` в `config.sh` и сверьтесь, чтобы все названия файлов совпадали в `CURSOR_ACTIONS`. Если какой-то файл не будет найден, он будет пропущен.
8. Запустите файл `cursor_install.sh`. Если всё пройдёт успешно, то в папке с проектом и в `PATH_TO_INSTALL` появится ваша папка с курсорами. Дальнейшие действия зависят от вашей системы. В KDE Plasma ваш курсор появится в параметрах системы.

## Более детальные объяснения как работает скрипт
### cursor_converting.sh
1. При запуске `cursor_converting.sh` создаются директории  `PATH_TO_XCURSOR`, `PATH_TO_XCURSOR/post-processing` и `PATH_TO_ADAPT_XCURSOR`
2. При `CONVERT_WINDOWS_CURSOR=1` скрипт переходит в директорию `PATH_TO_ANI_CUR_CURSORS` и выполняет преобразование всех файлов .ani/.cur в формат XCursor через утилиту `win2xcur`. Все XCursor файлы сохраняются в папку `PATH_TO_XCURSOR`
3. Скрипт переходит в папку `PATH_TO_XCURSOR` и получает список всех файлов. Каждый XCursor файл преобразуется в серию **.png** изображений и **.conf** конфиг курсора, где прописана информация о каждом кадре (путь до png изображения, хитбокс курсора, задержка анимации и размер курсора)
4. Все **.png** изображения и **.conf** файлы перемещаются в папку `PATH_TO_XCURSOR/post-processing`, чтобы не захламлять всё остальное
5. Каждый **.conf** файл анализируется и выискивается самый большой размер курсора. Чаще всего это 32.
6. Вновь анализируем **.conf** файл. Преобразовываем через ImageMagick каждую **.png** картинку в разный размер (что прописали в `CURSOR_SIZES`). Условно `Normal_001.png` будет превращён в `12px_Normal_001.png`, `18px_Normal_001.png` и так далее
7. Вычисляем новый хитбокс у курсора. Например, у курсора хитбокс X=15, Y=15. Если мы увеличим курсор в два раза, то хитбокс станет X=30, Y=30. Это всё вычисляем и записываем.
8. Все изменения записываем в **.conf** файл (в терминал будут выводиться строчки, что записываются в файл)
9. При помощи `xcursorgen` из **.conf** файла и **.png** изображений собираем готовый XCursor файл.

### cursor_install.sh
1. Запускаем `./cursor_converting.sh`, если `CONVERTING=1`
2. Копируем папку шаблона (`PATH_TO_TEMPLATE`) под новым именем (`PACK_NAME`)
3. В данной папке создаём файл `index.theme` и `cursor.theme` с названием нашего пака и описанием
4. Анализируем `CURSOR_ACTIONS`. Ищем такой файл в `PATH_TO_ADAPT_XCURSOR`, копируем его в наш пак
5. Создаём символьные ссылки на те файлы, что прописаны в `CURSOR_ACTIONS` (например, `default`, `pointer` и так далее)
6. Если `INSTALL_CURSOR_PACK=1` то копируем нашу папку в `PATH_TO_INSTALL`
