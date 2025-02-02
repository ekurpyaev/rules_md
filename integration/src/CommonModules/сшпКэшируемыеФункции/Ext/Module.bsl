﻿
#Область ПрограммныйИнтерфейс

// Функция - Получить HTTPЗапрос
//
// Параметры:
//  Сервис - Строка - адрес web-сервиса.
//  Точка - Строка - имя точки web-сервиса.
//  Формат - Перечисление.сшпФорматыСообщений - формат сообщения. 
// 
// Возвращаемое значение:
// HTTPЗапрос - объект типа HTTPЗапрос.
//
Функция ПолучитьHTTPЗапрос(Сервис, Точка, Формат) Экспорт
	
	httpЗапрос = Новый HTTPЗапрос;
	httpЗапрос.АдресРесурса = Сервис + Точка;
	httpЗапрос.Заголовки.Вставить("Content-type", ПолучитьОписаниеТипаСообщения(Формат));
	
	Возврат httpЗапрос; 

КонецФункции	

// Функция - Получить тип сообщения
//
// Параметры:
//  ОписаниеТипа - Строка - строка с описанием формата сообщения.
// 
// Возвращаемое значение:
//  Перечисления.сшпФорматыСообщений - формат сообщения по указанному описанию.
//
Функция ПолучитьТипСообщения(ОписаниеТипа) Экспорт
	
	текВозврат = Неопределено;
	
	Если ОписаниеТипа = "application/json;charset=utf-8" Тогда
		
		текВозврат = Перечисления.сшпФорматыСообщений.JSON;		
	
	ИначеЕсли ОписаниеТипа = "application/xml;charset=utf-8" Тогда
		
		текВозврат = Перечисления.сшпФорматыСообщений.XML;
	
	ИначеЕсли ОписаниеТипа = "raw" Тогда
		
		текВозврат = Перечисления.сшпФорматыСообщений.FastInfoset;
	
	КонецЕсли;	
	
	Возврат текВозврат;
	
КонецФункции	

// Функция - Получить описание типа сообщения
//
// Параметры:
//  ФорматСообщений - Перечисления.сшпФорматыСообщений - формат сообщения для которого необходимо получить строковое описание.
// 
// Возвращаемое значение:
//  Строка - описание формата сообщений.
//
Функция ПолучитьОписаниеТипаСообщения(ФорматСообщений) Экспорт
	
	текВозврат = Неопределено;
	
	Если ФорматСообщений = Перечисления.сшпФорматыСообщений.JSON Тогда
				
		текВозврат = "text/json";
				
	ИначеЕсли ФорматСообщений = Перечисления.сшпФорматыСообщений.XML Тогда
		
		текВозврат = "text/xml";
				
	ИначеЕсли ФорматСообщений = Перечисления.сшпФорматыСообщений.FastInfoset Тогда
		
		текВозврат = "raw";
		
	КонецЕсли;	
	
	Возврат текВозврат;
	
КонецФункции	

// Функция - Участвует в интеграции
//
// Параметры:
//  ТипОбъекта - Строка - тип объекта для проверки участия в интеграции. 
//  КлючАктуальности - Строка - ключ актуалного состояния списка объектов интеграции (для обновления кэшированного значения функции).
// 
// Возвращаемое значение:
//  Булево - Признак участия в исходящем потоке интеграции.
//
Функция УчаствуетВИнтеграции(ТипОбъекта, КлючАктуальности = Неопределено) Экспорт
	
	текРезультатПроверки = Ложь;
	
	Если сшпФункциональныеОпции.ИспользоватьСШП() Тогда
		
		текЗапрос = Новый Запрос("ВЫБРАТЬ
		|	тбРепозиторий.ИмяКлассаОбъекта
		|ИЗ
		|	РегистрСведений.сшпРепозиторийОбъектовИнтеграции КАК тбРепозиторий
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.сшпСтатусыОбработчиков КАК сшпСтатусыОбработчиков
		|		ПО тбРепозиторий.ИдентификаторШаблона = сшпСтатусыОбработчиков.ИдентификаторОбработчика
		|			И (НЕ сшпСтатусыОбработчиков.Статус = ЗНАЧЕНИЕ(Перечисление.сшпСтатусыОбработчиков.Отключен))
		|ГДЕ
		|	тбРепозиторий.ИмяКлассаОбъекта = &ИмяКлассаОбъекта
		|	И тбРепозиторий.ТипИнтеграции = ЗНАЧЕНИЕ(Перечисление.сшпТипыИнтеграции.Исходящая)");
		текЗапрос.Параметры.Вставить("ИмяКлассаОбъекта", ТипОбъекта);
		
		текРезультат = текЗапрос.Выполнить();
		
		текРезультатПроверки = Не текРезультат.Пустой();
	
	КонецЕсли;
	
	Возврат  текРезультатПроверки;

КонецФункции	

// Функция - Получить обработчик
//
// Параметры:
//  ТипОбъекта - Строка - описание имени объекта/класса.
//  Направление - Перечисление.сшпТипыИнтеграции - направление потока данных.
//  Ключ - Строка - ключ актуалного состояния списка объектов интеграции (для обновления кэшированного значения функции). 
// 
// Возвращаемое значение:
//  Структура - Описание обработчика 
//
Функция ПолучитьОбработчик(ТипОбъекта, Направление, Ключ) Экспорт
	
	сткВозврат = сшпОбщегоНазначения.ПолучитьСтруктуруОписанияОбработчика();
	
	текЗапрос = Новый Запрос("ВЫБРАТЬ
	|	тбРепозиторий.Наименование КАК Наименование,
	|	тбРепозиторий.ПроцедураОбработки,
	|	тбРепозиторий.ИдентификаторШаблона,
	|	тбРепозиторий.Версия,
	|	тбСтатусы.Статус
	|ИЗ
	|	РегистрСведений.сшпРепозиторийОбъектовИнтеграции КАК тбРепозиторий
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.сшпСтатусыОбработчиков КАК тбСтатусы
	|		ПО тбРепозиторий.ИдентификаторШаблона = тбСтатусы.ИдентификаторОбработчика
	|ГДЕ
	|	тбРепозиторий.ИмяКлассаОбъекта = &ИмяКлассаОбъекта
	|	И тбРепозиторий.ТипИнтеграции = &ТипИнтеграции");	
	текЗапрос.УстановитьПараметр("ИмяКлассаОбъекта", ТипОбъекта);
	текЗапрос.УстановитьПараметр("ТипИнтеграции", Направление);
	
	текРезультат = текЗапрос.Выполнить();
	
	Если Не текРезультат.Пустой() Тогда
		
		текВыборка = текРезультат.Выбрать();
		текВыборка.Следующий();
		
		сткВозврат.ОбработчикНайден 	= ЗначениеЗаполнено(текВыборка.ПроцедураОбработки);
		сткВозврат.Отключен			 	= текВыборка.Статус = Перечисления.сшпСтатусыОбработчиков.Отключен;
		сткВозврат.Наименование 		= текВыборка.Наименование;
		сткВозврат.ПроцедураОбработки 	= текВыборка.ПроцедураОбработки;
		сткВозврат.ИдентификаторШаблона	= текВыборка.ИдентификаторШаблона;
		сткВозврат.Версия 				= текВыборка.Версия;
		сткВозврат.Статус 				= текВыборка.Статус;
		
	КонецЕсли;
		
	Возврат Новый ФиксированнаяСтруктура(сткВозврат);
	
КонецФункции	

// Функция - Получить обработчик по имени
//
// Параметры:
//  НаименованиеОбработчика - Строка - Наименование обработчика
//
// Возвращаемое значение:
//  Структура - Описание обработчика 
//
Функция ПолучитьОбработчикПоИмени(НаименованиеОбработчика) Экспорт
	
	сткВозврат = сшпОбщегоНазначения.ПолучитьСтруктуруОписанияОбработчика();
	
	текЗапрос = Новый Запрос("ВЫБРАТЬ
	|	тбРепозиторий.Наименование КАК Наименование,
	|	тбРепозиторий.ПроцедураОбработки,
	|	тбРепозиторий.ИдентификаторШаблона,
	|	тбРепозиторий.Версия,
	|	тбСтатусы.Статус
	|ИЗ
	|	РегистрСведений.сшпРепозиторийОбъектовИнтеграции КАК тбРепозиторий
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.сшпСтатусыОбработчиков КАК тбСтатусы
	|		ПО тбРепозиторий.ИдентификаторШаблона = тбСтатусы.ИдентификаторОбработчика
	|ГДЕ
	|	тбРепозиторий.Наименование = &НаименованиеОбработчика");	
	текЗапрос.УстановитьПараметр("НаименованиеОбработчика", НаименованиеОбработчика);
	
	текРезультат = текЗапрос.Выполнить();
	
	Если Не текРезультат.Пустой() Тогда
		
		текВыборка = текРезультат.Выбрать();
		текВыборка.Следующий();
		
		сткВозврат.ОбработчикНайден 	= ЗначениеЗаполнено(текВыборка.ПроцедураОбработки);
		сткВозврат.Отключен			 	= текВыборка.Статус = Перечисления.сшпСтатусыОбработчиков.Отключен;
		сткВозврат.Наименование 		= текВыборка.Наименование;
		сткВозврат.ПроцедураОбработки 	= текВыборка.ПроцедураОбработки;
		сткВозврат.ИдентификаторШаблона	= текВыборка.ИдентификаторШаблона;
		сткВозврат.Версия 				= текВыборка.Версия;
		сткВозврат.Статус 				= текВыборка.Статус;
		
	КонецЕсли;
		
	Возврат Новый ФиксированнаяСтруктура(сткВозврат);
	
КонецФункции

// Функция - Получить метод хранения
//
// Параметры:
//  ТипОбъекта - Строка - тип объекта для проверки участия в интеграции. 
//  КлючАктуальности - Строка - ключ актуалного состояния списка объектов интеграции (для обновления кэшированного значения функции)
// 
// Возвращаемое значение:
//  Перечисление.сшпМетодХранения - текущий метод хранения данных объекта события. 
//
Функция ПолучитьМетодХранения(ТипОбъекта, КлючАктуальности = Неопределено) Экспорт
	
	методХранения = Перечисления.сшпМетодХранения.Сериализация;
	
	текЗапрос = Новый Запрос("ВЫБРАТЬ
	|	тбРепозиторий.МетодХранения
	|ИЗ
	|	РегистрСведений.сшпРепозиторийОбъектовИнтеграции КАК тбРепозиторий
	|ГДЕ
	|	тбРепозиторий.ИмяКлассаОбъекта = &ИмяКлассаОбъекта
	|	И тбРепозиторий.ТипИнтеграции = ЗНАЧЕНИЕ(Перечисление.сшпТипыИнтеграции.Исходящая)");
	текЗапрос.Параметры.Вставить("ИмяКлассаОбъекта", ТипОбъекта);
	
	текРезультат = текЗапрос.Выполнить();
	
	Если Не текРезультат.Пустой() Тогда
		
		выборкаМетод = текРезультат.Выбрать();
		выборкаМетод.Следующий();
		
		методХранения = выборкаМетод.МетодХранения;
		
	КонецЕсли;
	
	Возврат  методХранения;
	
КонецФункции

// Функция - Получить имя объекта
//
// Параметры:
//  типобъекта - Строка - возвращает имя объекта по переданному типу.
// 
// Возвращаемое значение:
//  Строка - имя объекта.
//
Функция ПолучитьИмяОбъекта(ТипОбъекта) Экспорт
	
	ИмяОбъекта = Прав(ТипОбъекта, СтрДлина(ТипОбъекта) - Найти(ТипОбъекта, ".")); // Для старых версий платформы.
	
	Возврат ИмяОбъекта;
	
КонецФункции	

// Функция - Получить тип объекта
//
// Параметры:
//  ТипОбъекта - Строка - Представление типа объекта метаданных
// 
// Возвращаемое значение:
//  Строка - тип объекта.
//
Функция ПолучитьТипОбъекта(ТипОбъекта) Экспорт
	
	ТипОбъектаМетаданных = Лев(ТипОбъекта, Найти(ТипОбъекта, ".") - 1); // Для старых версий платформы.
	
	Возврат ТипОбъектаМетаданных;
	
КонецФункции

// Функция - Получить хэш-сумму
//
// Параметры:
//  Текст - Строка - текст, которых необходимо захэшировать.
//
// Возвращаемое значение:
//  Число - значение хэш-суммы.
//
Функция ПолучитьХэшСумму(Текст) Экспорт
	
	хэшТекста = Новый ХешированиеДанных(ХешФункция.CRC32);
	
	хэшТекста.Добавить(Текст);
	
	Возврат хэшТекста.ХешСумма;
	
КонецФункции	

// Функция - Получить список рабочих статусов
//
// Возвращаемое значение:
//  Массив - массив, сождержащий элементы перечисления "Статусы сообщений" (См. Перечисления.сшпСтатусыСообщений)
//
Функция ПоучитьСписокРабочихСтатусов() Экспорт
	
	массивСтатусы = Новый Массив;
	массивСтатусы.Добавить(Перечисления.сшпСтатусыСообщений.Новое);
	массивСтатусы.Добавить(Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки);
	
	Возврат массивСтатусы;
	
КонецФункции	

// Функция - Это системное сообщение
//
// Параметры:
//  ТипСообщения - Строка - тип сообщения. 
// 
// Возвращаемое значение:
//  Булево - признак, является ли сообщение данного типа системным.
//
функция ЭтоСистемноеСообщение(ТипСообщения) Экспорт
	
	РезультатВозврат = Ложь;
	
	Если ТипСообщения = "TRM"		// Команда на удаление обработчика события
		ИЛИ ТипСообщения = "TUM" 	// Сообщение для обновления обработчиков событий и состава зарегистрированных объектов
		ИЛИ ТипСообщения = "TLR" 	// Запрос на получение списка версий обработчиков
		ИЛИ ТипСообщения = "TSR" 	// Запрос на получение списка обработчиков
		ИЛИ ТипСообщения = "TCS" 	// Команда на изменение состояния обработчика
		ИЛИ ТипСообщения = "FRM"	// Команда на удаление функции
		ИЛИ ТипСообщения = "FUM" 	// Сообщение для обновления функции 
		ИЛИ ТипСообщения = "FLR" 	// Запрос на получение списка версий функций
		ИЛИ ТипСообщения = "FSR" 	// Запрос на получение списка функций
		ИЛИ ТипСообщения = "FCS" 	// Команда на изменение состояния функции
		ИЛИ ТипСообщения = "RML" 	// Команда на возврат в обработку пакетов в состоянии "Ошибка обработки"
		ИЛИ ТипСообщения = "BMR" 	// Запрос структуры конфигурации
		ИЛИ ТипСообщения = "V1C" 	// Запрос версии подсистемы 1С
		ИЛИ ТипСообщения = "CSB" 	// Запрос строки подключения
		ИЛИ ТипСообщения = "DEB" 	// debug
		ИЛИ ТипСообщения = "GPS" 	// Запрос состояния обработки get processing status
		ИЛИ ТипСообщения = "FND" 	// Поиск сообщений
		ИЛИ ТипСообщения = "ACK"	// Подтверждение
	Тогда
		       
		РезультатВозврат = Истина;
		
	КонецЕсли;
	
	Возврат РезультатВозврат;
	
КонецФункции

// Функция - Это транспортное сообщение
//
// Параметры:
//  ТипСообщения - Строка - тип сообщения.
// 
// Возвращаемое значение:
//  Булево - признак, является ли сообщение данного типа транспортным.
//
Функция ЭтоТранспортноеСообщение(ТипСообщения) Экспорт
	
	РезультатВозврат = Ложь;
	
	Если ТипСообщения = "DTP" Тогда	// Сообщение передачи данных.
	
		РезультатВозврат = Истина;
		
	КонецЕсли;
	
	Возврат РезультатВозврат;
	
КонецФункции

// Функция - Это командное сообщение
//
// Параметры:
//  ТипСообщения - Строка - тип сообщения. 
// 
// Возвращаемое значение:
//  Булево - признак, является ли сообщение данного типа командным.
//
функция ЭтоКомандноеСообщение(ТипСообщения) Экспорт
	
	РезультатВозврат = Ложь;
	
	Если ТипСообщения = "GCM" 		// Команда на выполнение произвольного кода
		ИЛИ ТипСообщения = "CSM" 	// Команда на запуск пула обработчиков
		ИЛИ ТипСообщения = "CSA" 	// Команда на изменение параметров подключения к адаптеру
		ИЛИ ТипСообщения = "SUS" 	// Команда на установку настроек пользователя сервиса
	Тогда
		           
		РезультатВозврат = Истина;
		
	КонецЕсли;
	
	Возврат РезультатВозврат;
	
КонецФункции

// Функция - Получить значение атрибута типа
//
// Параметры:
//  ТипСообщения - входящий тип для определния атрибута.
// 
// Возвращаемое значение:
// Строка  -  атрибут, соответствующий типу.
//
Функция ПолучитьЗначениеАтрибутаТипа(ТипЗначения) Экспорт
	
	ВозвратСтрока = Неопределено;
	
	Если ТипЗначения = Тип("Булево") Тогда
		
		ВозвратСтрока = "xs:boolean";
		
	ИначеЕсли ТипЗначения = Тип("Число") Тогда
		
		ВозвратСтрока = "xs:int";
		
	ИначеЕсли ТипЗначения = Тип("Строка") Тогда
		
		ВозвратСтрока = "xs:String";
		
	КонецЕсли;
		
	Возврат ВозвратСтрока;
	
КонецФункции

// Функция - Получить структуру объекта
//
// Параметры:
//  ссылка - ссылка на объект, структуру которого следует получить.
//
Функция ПолучитьСтруктуруОбъекта(Ссылка) Экспорт
	
КонецФункции	

// Функция - Версия подсистемы
//
// Возвращаемое значение:
//  Строка - номер текущей версии подсистемы ESB 
//
Функция ВерсияПодсистемы() Экспорт
	 
	ТекущаяВерсия = Константы.сшпВерсияПодсистемы.Получить();
	
	Если ТекущаяВерсия = 0 Тогда
		 
		ТекущаяВерсия = 10000;
		
	КонецЕсли;

	Возврат ТекущаяВерсия;
	
КонецФункции

// Функция - ДлительностьОжиданияПриАвтоматическомСтарте
//
// Возвращаемое значение:
//	Число - длительность ожидания
//
функция ДлительностьОжиданияПриАвтоматическомСтарте() Экспорт
	 
	Возврат 15;
	
КонецФункции

// Функция - ПолучитьКомпоненту
//	Используется для Windows x64/x86 и Linux x64
//
// Параметры:
//	ИмяЭкземпляра - Строка - Имя экземпляра компоненты
//	
Функция ПолучитьКомпоненту(ИмяЭкземпляра = "") Экспорт
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	
	Если СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда 
		
		ИмяКомпоненты = "ОбщийМакет.сшпКомпонентаWin64";
	
	ИначеЕсли СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86 Тогда
		
		ИмяКомпоненты = "ОбщийМакет.сшпКомпонентаWin86";
	
	ИначеЕсли СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Linux_x86_64 Тогда 
		
		ИмяКомпоненты = "ОбщийМакет.сшпКомпонентаLinux64";
	
	Иначе
		
		ЗаписьЖурналаРегистрации("Datareon.ПолучитьВнешнююКомпоненту", УровеньЖурналаРегистрации.Примечание, Метаданные.ОбщиеМодули.сшпКэшируемыеФункции, , НСтр("ru = 'Для платформы " + СистемнаяИнформация.ТипПлатформы + " использование внешней компоненты не поддерживается.'"));
		
		Возврат Неопределено;
	
	КонецЕсли;

	РезультатПодключения = ПодключитьВнешнююКомпоненту(ИмяКомпоненты,"datareon", ТипВнешнейКомпоненты.Native);
	
	Если Не РезультатПодключения Тогда
				
		ЗаписьЖурналаРегистрации("Datareon.ПолучитьВнешнююКомпоненту", УровеньЖурналаРегистрации.Ошибка, Метаданные.ОбщиеМодули.сшпКэшируемыеФункции, , НСтр("ru = 'Для платформы " + СистемнаяИнформация.ТипПлатформы + " не удалось загрузить внешнюю компоненту.'"));
		
		Возврат Неопределено;
	
	КонецЕсли;

	Возврат Новый("AddIn.datareon.AddInNativeExtension");	

КонецФункции

// Функция - Удалить получить код состояния обработки
//
// Параметры:
//	Состояние - Перечисление.сшпСтатусыСообщений - состояние сообщения
//
// Возвращаемое значение:
//	Число - Код состояния обработки
//
Функция УдалитьПолучитьКодСостоянияОбработки(Состояние) Экспорт
	
	Если Состояние = Перечисления.сшпСтатусыСообщений.Обработано Тогда
		
		Возврат 0;
		
	ИначеЕсли (Состояние = Перечисления.сшпСтатусыСообщений.НеВалидно) Тогда
		
		Возврат 1;
		
	ИначеЕсли (Состояние = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки) Тогда
		
		Возврат 4;
		
	Иначе
		
		Возврат 2;
		
	КонецЕсли;
	 
КонецФункции

// Функция - Получить общий код состояния обработки
//
// Параметры:
//	Состояние - Перечисление.сшпСтатусыСообщений - состояние сообщения
//	Направление - Перечиление.сшпТипыИнтеграции - направление интеграции
//
// Возвращаемое значение:
//	Число - Код состояния обработки
//
Функция ПолучитьОбщийКодСостоянияОбработки(Состояние, Направление) Экспорт
	
	КодСтатуса = -1;
	
	Если Направление = Перечисления.сшпТипыИнтеграции.Входящая Тогда
		
		Если Состояние = Перечисления.сшпСтатусыСообщений.Обработано Тогда
			
			КодСтатуса = 0;
			
		ИначеЕсли Состояние = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки Тогда
			
			КодСтатуса = 1;
			
		ИначеЕсли Состояние = Перечисления.сшпСтатусыСообщений.ОтсутствуетОбработчик ИЛИ
			Состояние = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки Тогда
			
			КодСтатуса = 2;
			
		ИначеЕсли Состояние = Перечисления.сшпСтатусыСообщений.НеВалидно Тогда		 	
			
			КодСтатуса = 3;
			
		ИначеЕсли Состояние = Перечисления.сшпСтатусыСообщений.ОбработкаОтменена Тогда
			
			КодСтатуса = 10;
			
		КонецЕсли;
		
	Иначе
		
		Если Состояние = Перечисления.сшпСтатусыСообщений.ОтсутствуетОбработчик ИЛИ 
			Состояние = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки Тогда
			
			КодСтатуса = 4;
			
		ИначеЕсли Состояние = Перечисления.сшпСтатусыСообщений.ОбработкаОтменена Тогда
			
			КодСтатуса = 10;	
			
		КонецЕсли;
		
	КонецЕсли;	
	
	Возврат КодСтатуса;
	
КонецФункции

// Функция - Получить общее состояние обработки сообщения по коду
//
// Параметры:
//	КодСостояния - Число - код состояния сообщения
//
// Возвращаемое значение:
//	Перечисление.сшпСтатусыСообщений - состояние обработки
//
Функция ПолучитьОбщееСостояниеОбработкиСообщенияПоКоду(КодСостояния) Экспорт
		
	Если КодСостояния = 0 Тогда
		
		Возврат Перечисления.сшпСтатусыСообщений.ОтправкаПодтверждена;
		
	ИначеЕсли КодСостояния = 1 Тогда
		
		Возврат Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
		
	ИначеЕсли КодСостояния = 2 Тогда
		
		Возврат  Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
		
	ИначеЕсли КодСостояния = 3 Тогда
		
		Возврат Перечисления.сшпСтатусыСообщений.ОбработкаОтменена;
		
	ИначеЕсли КодСостояния = 4 Тогда
		
		Возврат Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
		
	ИначеЕсли КодСостояния = 10 Тогда
		
		Возврат Перечисления.сшпСтатусыСообщений.ОбработкаОтменена;
		
	Иначе
		
		Возврат Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
		
	КонецЕсли;
	
КонецФункции

// Функция - ПолучитьСостоянияОбработкиСообщенияПоКоду
//
// Параметры:
//	КодСостояния - Число - код состояния сообщения
//
// Возвращаемое значение:
//	Перечисление.сшпСтатусыСообщений - состояние обработки
//
Функция УдалитьПолучитьСостоянияОбработкиСообщенияПоКоду(КодСостояния) Экспорт
	
	Если КодСостояния = 0 Тогда
		
		Возврат Перечисления.сшпСтатусыСообщений.ОтправкаПодтверждена;
		
	ИначеЕсли КодСостояния = 1 Тогда
		
		Возврат Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
		
	ИначеЕсли КодСостояния = 2 Тогда
		
		Возврат Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
		
	Иначе
		
		Возврат Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
		
	КонецЕсли;
	 
КонецФункции

// Функция - ФорматСообщенийПоУмолчанию
//
// Возвращаемое значение:
//	Перечисление.сшпФорматыСообщений - формат сообщения по умолчанию
//
Функция ФорматСообщенийПоУмолчанию() Экспорт
	
	Возврат Перечисления.сшпФорматыСообщений.XML;
	
КонецФункции

// Функция - ПолучитьОбъектНабораЗаписейСостоянияСообщений
//
// Возвращаемое значение:
//	 РегистрСведенийНаборЗаписей - набор записей регистра сшпСостояниеСообщений
//
Функция ПолучитьОбъектНабораЗаписейСостоянияСообщений() Экспорт
	
	Набор = РегистрыСведений.сшпСостояниеСообщений.СоздатьНаборЗаписей();
	Набор.ДополнительныеСвойства.Вставить("СШПНеобрабатывать", Истина);
	
	Возврат Набор;
	
КонецФункции

// Функция - выполнение подготовленной функции
//
//Параметры:
//	ИмяФункции - Строка - Имя выполняемой функции, соотвествующее наименованию объекта интеграции
//	ТекстФункции - Строка - Подготовленный текст выполняемой функции
//	ПараметрыФункции - Структура - Структура параметров функции, ключи структуры должны соответствовать именам переменных функции
//
//Возвращаемое значение:
//	ЛюбоеЗначение - Возвращаемое значение зависит от вызываемой функции из объектов интеграции 
Функция ВыполнитьКешируемуюФункцию(ИмяФункции, ТекстФункции, ПараметрыФункции) Экспорт
	
	Результат = Неопределено;
	
	Попытка
		Выполнить(ТекстФункции);
	Исключение
		сшпСистемныеСообщения.ОтправитьСообщениеОбОшибке("Выполнение функции " + ИмяФункции, "При выполнении функции была обнаружена ошибка, " + ОписаниеОшибки(), Новый Структура());
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти
