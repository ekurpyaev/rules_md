﻿
#Область ПрограммныйИнтерфейс

// Процедура - Запустить задания обработки очереди входящих сообщений
// 
Процедура ЗапуститьЗаданияОбработкиВходящихСообщений() Экспорт 
	
	воВходящиеОчередиВызовСервера.ЗапуститьЗаданияОбработкиВходящихСообщений();
	воВходящиеОчередиВызовСервера.ЗапуститьЗаданияОчисткиОчередиВходящихСообщений();
	воВходящиеОчередиВызовСервера.ЗапуститьЗаданиеОбновленияСтатистикиВнутреннихОчередей();

КонецПроцедуры

// Функция - Получить объект XDTO
//
// Параметры:
//  ФорматСообщения - Перечисление.воФорматыСообщений - текущий формат сообщения.
//  ТелоСообщения - Строка - Текстовое представление сообщения в указанном формате.
//  ТипОбъекта - ТипЗначенияXDTO, ТипОбъектаXDTO - Тип элемента данных XDTO
//  
// Возвращаемое значение:
//  ОбъектXDTO - объект сформированный фабрикойXDTO из исходного текста. В случае невозможности преобразования возвращается Неопределено.  
//
Функция ПолучитьОбъектXDTO(ФорматСообщения, ТелоСообщения, ТипОбъекта = Неопределено) Экспорт
	
	ТекОбъект = Неопределено;
	
	Попытка
		
		ТекЧтение = ПолучитьОбъектПотоковогоЧтения(ФорматСообщения, ТелоСообщения);
		
		Если Не ТекЧтение = Неопределено Тогда
		
			ТекОбъект = ПрочитатьОбъектИзПотока(ФорматСообщения, ТекЧтение, ТипОбъекта);
			
		КонецЕсли;
		
	Исключение
		
		Если Не ЗначениеЗаполнено(ТелоСообщения) Тогда
			
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Datareon.ПолучитьОбъектСообщения'"), УровеньЖурналаРегистрации.Ошибка, , , НСтр("ru = 'Не удалось получить объект XDTO, поле Body не содержит значения'"));
			
		Иначе
			
			ИнформацияОбОшибке = ИнформацияОбОшибке();
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Datareon.ПолучитьОбъектСообщения'"), УровеньЖурналаРегистрации.Ошибка, Метаданные.ОбщиеМодули.воОбщегоНазначенияВызовСервера, , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
			
		КонецЕсли;
		
	КонецПопытки;
	
	Возврат ТекОбъект;
	
КонецФункции	

// Функция - Получить объект потокового чтения
//
// Параметры:
//  Формат - Перечисление.воФорматыСообщений - текущий формат сообщения.
//  ЧитаемаяСтрока	 - 	 - .
// 
// Возвращаемое значение:
//  ЧтениеXML, ЧтениеFastInfoset, ЧтениеJSON  - объект потокового чтения заданного формата.
//
Функция ПолучитьОбъектПотоковогоЧтения(Формат, ЧитаемаяСтрока) Экспорт
	
	ТекОбъект = Неопределено;
	
	Если Формат = Перечисления.воФорматыСообщений.XML Тогда
		
		ТекОбъект = воФункцииРаботыXMLВызовСервера.ПолучитьОбъектПотоковогоЧтения(ЧитаемаяСтрока);
		
	ИначеЕсли Формат = Перечисления.воФорматыСообщений.JSON Тогда
		
		ТекОбъект = воФункцииРаботыJSONВызовСервера.ПолучитьОбъектПотоковогоЧтения(ЧитаемаяСтрока);
		
	ИначеЕсли Формат = Перечисления.воФорматыСообщений.FastInfoset Тогда
		
		ТекОбъект = воФункцииРаботыFastInfosetВызовСервера.ПолучитьОбъектПотоковогоЧтения(ЧитаемаяСтрока);
		
	КонецЕсли;
	
	Возврат ТекОбъект;
	
КонецФункции

// Функция - Прочитать объект из потока
//
// Параметры:
//  Формат - Перечисление.воФорматыСообщений - текущий формат сообщения.
//  Поток - Строка - строка описания объекта в заданном формате.
//  ТипОбъекта - ТипЗначенияXDTO, ТипОбъектаXDTO - Тип элемента данных XDTO
// 
// Возвращаемое значение:
//  ЛюбаяСсылка, ЛюбойОбъект - объект прочитанный фабрикой XDTO из указанного формата. 
//
Функция ПрочитатьОбъектИзПотока(Формат, Поток, ТипОбъекта) Экспорт
	
	ТекОбъект = Неопределено;
	
	Попытка
		
		Если Формат = Перечисления.воФорматыСообщений.XML Тогда
			
			ТекОбъект = воФункцииРаботыXMLВызовСервера.ПрочитатьОбъектИзПотока(Поток, ТипОбъекта);
			
		ИначеЕсли Формат = Перечисления.воФорматыСообщений.JSON Тогда
			
			ТекОбъект = воФункцииРаботыJSONВызовСервера.ПрочитатьОбъектИзПотока(Поток, ТипОбъекта);
			
		ИначеЕсли Формат = Перечисления.воФорматыСообщений.FastInfoset Тогда
			
			ТекОбъект = воФункцииРаботыFastInfosetВызовСервера.ПрочитатьОбъектИзПотока(Поток, ТипОбъекта);
			
		КонецЕсли;
		
	Исключение
		
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Datareon.Формирование объекта XDTO'"), УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));		
	
	КонецПопытки;
	
	Возврат ТекОбъект;

КонецФункции

// Формирует и выводит сообщение, которое может быть связано с элементом управления формы.
//
// Параметры:
//  ТекстСообщенияПользователю - Строка - текст сообщения.
//  КлючДанных - ЛюбаяСсылка - объект или ключ записи информационной базы, к которому это сообщение относится.
//  Поле - Строка - наименование реквизита формы.
//  ПутьКДанным - Строка - путь к данным (путь к реквизиту формы).
//  Отказ - Булево - выходной параметр, всегда устанавливается в значение Истина.
//
// Пример:
//
//  1. Для вывода сообщения у поля управляемой формы, связанного с реквизитом объекта:
//  ОбщегоНазначенияКлиент.СообщитьПользователю(
//   НСтр("ru = 'Сообщение об ошибке.'"), ,
//   "ПолеВРеквизитеФормыОбъект",
//   "Объект");
//
//  Альтернативный вариант использования в форме объекта:
//  ОбщегоНазначенияКлиент.СообщитьПользователю(
//   НСтр("ru = 'Сообщение об ошибке.'"), ,
//   "Объект.ПолеВРеквизитеФормыОбъект");
//
//  2. Для вывода сообщения рядом с полем управляемой формы, связанным с реквизитом формы:
//  ОбщегоНазначенияКлиент.СообщитьПользователю(
//   НСтр("ru = 'Сообщение об ошибке.'"), ,
//   "ИмяРеквизитаФормы");
//
//  3. Для вывода сообщения связанного с объектом информационной базы:
//  ОбщегоНазначенияКлиент.СообщитьПользователю(
//   НСтр("ru = 'Сообщение об ошибке.'"), ОбъектИнформационнойБазы, "Ответственный",,Отказ);
//
//  4. Для вывода сообщения по ссылке на объект информационной базы:
//  ОбщегоНазначенияКлиент.СообщитьПользователю(
//   НСтр("ru = 'Сообщение об ошибке.'"), Ссылка, , , Отказ);
//
//  Случаи некорректного использования:
//   1. Передача одновременно параметров КлючДанных и ПутьКДанным.
//   2. Передача в параметре КлючДанных значения типа отличного от допустимого.
//   3. Установка ссылки без установки поля (и/или пути к данным).
//
Процедура СообщитьПользователю( 
	Знач ТекстСообщенияПользователю,
	Знач КлючДанных = Неопределено,
	Знач Поле = "",
	Знач ПутьКДанным = "",
	Отказ = Ложь) Экспорт
	
	ЭтоОбъект = Ложь;
	
	Если КлючДанных <> Неопределено
		И XMLТипЗнч(КлючДанных) <> Неопределено Тогда
		
		ТипЗначенияСтрокой = XMLТипЗнч(КлючДанных).ИмяТипа;
		ЭтоОбъект = СтрНайти(ТипЗначенияСтрокой, "Object.") > 0;
	КонецЕсли;
	
	воОбщегоНазначенияСлужебныйКлиентСервер.СообщитьПользователю(
		ТекстСообщенияПользователю,
		КлючДанных,
		Поле,
		ПутьКДанным,
		Отказ,
		ЭтоОбъект);
	
КонецПроцедуры

// Функция - Получить текст ошибки обработчика
//
// Параметры:
//	ОшибкаОбработчика - ИнформацияОбОшибке - результат функции ИнформацияОбОшибке()
//
// Возвращаемое значение:
//  Строка - Текст ошибки обработчика
//
Функция ПолучитьТекстОшибкиОбработчика(Знач ОшибкаОбработчика) Экспорт
	
	Если ТипЗнч(ОшибкаОбработчика.Причина) = Тип("ИнформацияОбОшибке") Тогда
	
		Возврат СтрШаблон(НСтр("ru = 'Не удалось обработать сообщение %1'"), ПодробноеПредставлениеОшибки(ОшибкаОбработчика.Причина));
			
	Иначе
		
		Возврат СтрШаблон(НСтр("ru = 'Не удалось обработать сообщение %1'"), ПодробноеПредставлениеОшибки(ОшибкаОбработчика));
		
	КонецЕсли;
	
КонецФункции

// Функция - Дополнить текст ошибки 
// 
// Параметры:
// 	ТекстОшибки - Строка - Исходный текст ошибки
//	Обработчик - Структура - Структура описания обработчика
//	Объект - ЛюбаяСсылка - Объект ошибки
// 	
// Возвращаемое значение:
//  Строка - Дополненный текст ошибки
//
Функция ДополнитьТекстОшибки(ТекстОшибки, Обработчик, Объект) Экспорт
		
	Если ЗначениеЗаполнено(Объект) Тогда
		ТекстОбъекта = ", объект: " + Строка(Объект) + "/" + Объект.УникальныйИдентификатор();
	Иначе
		ТекстОбъекта = "";
	КонецЕсли;
		
	ТекстОшибки = СтрШаблон(НСтр("ru = 'При выполнении обработчика %1  [Версия: %2%3] произошла ошибка: %4'"), Обработчик.Наименование, Обработчик.Версия, ТекстОбъекта, ТекстОшибки);
	
	Возврат ТекстОшибки;
	
КонецФункции

// Функция - Получить количество попыток ожидания 
// 
// Параметры:
// 	ОбъектСообщение - ОбъектXDTO - Объект сообщения
// 	
// Возвращаемое значение:
//  Число - значение дополнительного свойства "DelayCount"
//
Функция ПолучитьКоличествоПопытокОжидания(ОбъектСообщение) Экспорт
	
	КоличествоПопытокОжидания = 0;
	
	Если Не ОбъектСообщение.Properties = Неопределено Тогда

		СтруктураСвойств = ПолучитьПараметрыСообщенияСтруктурой(ОбъектСообщение);
		
		Если Не СтруктураСвойств.Свойство("DelayCount", КоличествоПопытокОжидания) Тогда
			КоличествоПопытокОжидания = 0;
		КонецЕсли;
			
	КонецЕсли;
		
	Возврат КоличествоПопытокОжидания;
		
КонецФункции

// Функция - Получить параметры сообщения структурой
//
// Параметры:
//  Сообщение - ОбъектXDTO - объект типа Message1C 
// 
// Возвращаемое значение:
//  Структура - структура с дополнительными свойствами сообщения.
//
Функция ПолучитьПараметрыСообщенияСтруктурой(Сообщение) Экспорт
	
	СтруктураПараметры = Новый Структура;
	Если Не Сообщение = Неопределено Тогда
		
		xdtoСвойства = Сообщение.Properties.Последовательность();
		
		Если xdtoСвойства = Неопределено Тогда // В зависимости от вида сериализации это может быть список или последовательность.
			
			xdtoСвойства = Сообщение.Properties.ПолучитьСписок("MessageProperty");
			
			Для Каждого текПараметр Из xdtoСвойства Цикл
				
				СтруктураПараметры.Вставить(текПараметр.Name, ПолучитьЗначениеСвойстваСообщения(текПараметр));
				 
			КонецЦикла;
			
		Иначе
			 	
			КоличествоПараметры = xdtoСвойства.Количество();
					
			Если КоличествоПараметры > 0 Тогда
				
				Для Индекс = 0 По количествоПараметры - 1 Цикл
					
					текПараметр = xdtoСвойства.ПолучитьЗначениеXDTO(Индекс);
					структураПараметры.Вставить(текПараметр.Name, ПолучитьЗначениеСвойстваСообщения(текПараметр)); 
				
				КонецЦикла;
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат СтруктураПараметры;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Функция - Получить значение свойства сообщения
//
// Параметры:
//  свойство - ОбъектXDTO - свойство сообщения
// 
// Возвращаемое значение:
//  Любое значение - значение свойства сообщения 
//
Функция ПолучитьЗначениеСвойстваСообщения(Свойство)
	
	типСвойства = Свойство.Получить("Value/Type");
	типСвойства = ?(типСвойства = "Double", "Boolean", типСвойства);
	
	типСвойства1С = ?(НРег(типСвойства) = "integer", "Number", типСвойства);
	 
	Узел = Свойство.Получить("Value/"+типСвойства+"Values/");
	
	ЗначениеСвойства = Узел.Получить(Узел.Свойства().Get(0).Имя);
	
	Возврат ?(ЗначениеСвойства = null Или ЗначениеСвойства = Неопределено, Неопределено, XMLЗначение(Тип(типСвойства1С), ЗначениеСвойства));

КонецФункции

#КонецОбласти
