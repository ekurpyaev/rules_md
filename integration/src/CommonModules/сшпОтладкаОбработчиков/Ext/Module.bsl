﻿
// Функция - ВыполнитьОтладкуОбработчика
//
//Параметры:
//	ФорматСообщения - ПеречислениеСсылка.сшпФорматыСообщений - формат сообщения
//	Пакет - Строка - пакет с данными
//  текИдентификатор - УникальныйИдентификатор - идентификатор
//
// Возвращаемое значение:
// ЗаписьXML - параметры подключения к информационной базе 1С.
//
Функция ВыполнитьОтладкуОбработчика(ФорматСообщения, Пакет, текИдентификатор) Экспорт
	
	xdtoПакет = сшпОбщегоНазначения.ПолучитьОбъектXDTO(сшпКэшируемыеФункции.ФорматСообщенийПоУмолчанию(), Пакет);
	сткПараметры = сшпОбщегоНазначения.ПолучитьПараметрыСообщенияСтруктурой(xdtoПакет);
	
	ОписаниеОшибки = "";		 

	Если сткПараметры.Свойство("Type") Тогда                     
		
		ЭтоВходящийОбработчик = сткПараметры.Type = "InputHandler";
		
	Иначе
		
		ОписаниеОшибки = "В запросе отсутствует свойство Type";
		Возврат сшпВзаимодействиеСАдаптером.ОтправитьСистемноеСообщениеБезОчереди(СформироватьСообщениеСОшибкой(ОписаниеОшибки, текИдентификатор, xdtoПакет.ReplyTo));
		
	КонецЕсли;
	
	Если ЭтоВходящийОбработчик Тогда 
		
		ОбъектОбработки = сшпОбщегоНазначения.ПолучитьОбъектXDTO(сшпКэшируемыеФункции.ФорматСообщенийПоУмолчанию(), xdtoПакет.Body);
		
	Иначе
		
		УстановитьПривилегированныйРежим(Истина);
		НачатьТранзакцию();
		
		Попытка
			
			ОбъектОбработки = ВыполнитьПоискОбъектаОтладки(xdtoПакет.Body);
			
		Исключение
			
			ОписаниеОшибки = "Ошибка при поиске объекта для отладки: " + ОписаниеОшибки();
			
			Если ТранзакцияАктивна() Тогда 
				
				ОтменитьТранзакцию();
				
			КонецЕсли;
					
			Возврат сшпВзаимодействиеСАдаптером.ОтправитьСистемноеСообщениеБезОчереди(СформироватьСообщениеСОшибкой(ОписаниеОшибки, текИдентификатор, xdtoПакет.ReplyTo));		
			
		КонецПопытки;
		
		ОтменитьТранзакцию();
		
		Если ОбъектОбработки = Неопределено Тогда 
			
			ОписаниеОшибки = "Ошибка при поиске объекта для отладки: значение переменной ""ОбъектОбработки"" не установлено.";		
			Возврат сшпВзаимодействиеСАдаптером.ОтправитьСистемноеСообщениеБезОчереди(СформироватьСообщениеСОшибкой(ОписаниеОшибки, текИдентификатор, xdtoПакет.ReplyTo));		
			
		КонецЕсли;
		
		УстановитьПривилегированныйРежим(Ложь);
		
	КонецЕсли;
	
	КодОтладки = сткПараметры.Code;
	СостояниеСообщения = Перечисления.сшпСтатусыСообщений.Обработано; 
	
	//Выполнение кода
	РезультатОбработки = Неопределено;
	МассивЗамеров = Новый Массив;
	
	РезультатОтладки = Новый ТаблицаЗначений;   
	РезультатОтладки.Колонки.Добавить("ЗначениеПеременной");
	РезультатОтладки.Колонки.Добавить("ИмяПеременной");
	РезультатОтладки.Колонки.Добавить("ТипПеременной");
	РезультатОтладки.Колонки.Добавить("ПеременнаяНеОпределена");
	РезультатОтладки.Колонки.Добавить("НомерСтроки");
	РезультатОтладки.Колонки.Добавить("ВложенныеЗначения"); 
	
	НомерСтроки = 0;                                                                                                                       
	НачатьТранзакцию();   				                    			 
	
	Попытка 
		
		ИмяПрофиляБезопасности = "Datareon";
		УстановитьБезопасныйРежим(ИмяПрофиляБезопасности);
		
		Если БезопасныйРежим() = Истина Тогда //полученный профиль безопасности отсутствует
			
			УстановитьБезопасныйРежим(Ложь);
			
		КонецЕсли;
		
		УстановитьПривилегированныйРежим(Истина);	 
		
		Если ЭтоВходящийОбработчик Тогда 
			
			ВыполнитьКодОтладкиВходящий(КодОтладки, НомерСтроки, РезультатОтладки, ОбъектОбработки, ФорматСообщения, СостояниеСообщения, МассивЗамеров);	
			
		Иначе
			
			РезультатОбработки = ВыполнитьКодОтладкиИсходящий(КодОтладки, НомерСтроки, РезультатОтладки, ОбъектОбработки, ФорматСообщения, СостояниеСообщения, МассивЗамеров);	
			
		КонецЕсли;
		
	Исключение
		
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		
		НоваяСтрока = РезультатОтладки.Добавить();
		НоваяСтрока.ИмяПеременной = "Исключение";
		НоваяСтрока.ЗначениеПеременной = ИнформацияОбОшибке.Описание + ?(не ИнформацияОбОшибке.Причина = Неопределено, ": " + ИнформацияОбОшибке.Причина.Описание, "");
		НоваяСтрока.ТипПеременной = ИнформацияОбОшибке.ИсходнаяСтрока;
		НоваяСтрока.НомерСтроки = НомерСтроки;
		
		СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
		
	КонецПопытки;  	
	
	Если ТранзакцияАктивна() Тогда 
		
		ОтменитьТранзакцию();
		
	КонецЕсли;
	
	Если ТипЗнч(МассивЗамеров) = Тип("Массив") Тогда 
		
		СобраноСчетчиков = МассивЗамеров.Количество();
		
	Иначе
		
		СобраноСчетчиков = 0;
		
	КонецЕсли;
	
	xmlРезультат = Новый ЗаписьXML;
	xmlРезультат.УстановитьСтроку("UTF-8");
	xmlРезультат.ЗаписатьНачалоЭлемента("result");
	
	//Значения переменных
	РезультатОтладки.Колонки.Добавить("НомерИтерации");
	КоличествоИтераций = 0;
	НомерСтроки = -1;
	
	Для Каждого текСтрока Из РезультатОтладки Цикл 
		
		Если Не НомерСтроки = текСтрока.НомерСтроки Тогда
			
			КоличествоИтераций = КоличествоИтераций + 1;
			НомерСтроки = текСтрока.НомерСтроки;
			
		КонецЕсли;
		
		текСтрока.НомерИтерации = КоличествоИтераций;
		
	КонецЦикла;

	Для НомерИтерации = 1 По КоличествоИтераций Цикл 
		
		РезультатПоИтерации = РезультатОтладки.НайтиСтроки(Новый Структура("НомерИтерации", НомерИтерации));
		
		xmlРезультат.ЗаписатьНачалоЭлемента("row");
		xmlРезультат.ЗаписатьАтрибут("number", XMLСтрока(РезультатПоИтерации[0].НомерСтроки));
		xmlРезультат.ЗаписатьАтрибут("duration", ?(НомерИтерации <= СобраноСчетчиков, XMLСтрока(МассивЗамеров[НомерИтерации-1]), ""));
		
		Для Каждого текСтрока Из РезультатПоИтерации Цикл
			
			ЗаписатьЗначениеПеременной(xmlРезультат, текСтрока);
			
		КонецЦикла;
			
		xmlРезультат.ЗаписатьКонецЭлемента();
		
	КонецЦикла;
	
	//Результат выполнения обработчика
	xmlРезультат.ЗаписатьНачалоЭлемента("esbmessage");
	xmlРезультат.ЗаписатьАтрибут("result", XMLСтрока(СостояниеСообщения));
	
	Если Не ЭтоВходящийОбработчик И Не РезультатОбработки = Неопределено Тогда 
		
		xmlРезультат.ЗаписатьСекциюCDATA(сшпОбщегоНазначения.СформироватьСообщениеESB_HTTP(ФабрикаXDTO, РезультатОбработки));
		
	КонецЕсли;
	
	xmlРезультат.ЗаписатьКонецЭлемента();
		
	xmlРезультат.ЗаписатьКонецЭлемента();
	
	РезультатОбработки = сшпОбщегоНазначения.СформироватьСтруктуруПакета("SSM","Esb-DebugResult", xmlРезультат.Закрыть());
	РезультатОбработки.CorrelationId = текИдентификатор;
	РезультатОбработки.ReplyTo = xdtoПакет.ReplyTo;
	
	Возврат сшпВзаимодействиеСАдаптером.ОтправитьСистемноеСообщениеБезОчереди(РезультатОбработки);
	
КонецФункции

//Функция - Сформировать сообщение с ошибкой
//
//Параметры:
//	ОписаниеОшибки - Строка - Описание ошибки
//	CorrelationId - УникальныйИдентификатор - Идентификатор сообщения
//	ReplyTo - Строка - Получатель ответа
//
//Возвращаемое значение:
//	Структура - Пакет для передачи
//	
Функция СформироватьСообщениеСОшибкой(ОписаниеОшибки, CorrelationId, ReplyTo)
	
	xmlРезультат = Новый ЗаписьXML;
	xmlРезультат.УстановитьСтроку("UTF-8");
	xmlРезультат.ЗаписатьНачалоЭлемента("result");
	xmlРезультат.ЗаписатьНачалоЭлемента("request");
	xmlРезультат.ЗаписатьАтрибут("error", ОписаниеОшибки);
	xmlРезультат.ЗаписатьКонецЭлемента();
	xmlРезультат.ЗаписатьКонецЭлемента();
	
	РезультатОбработки = сшпОбщегоНазначения.СформироватьСтруктуруПакета("SSM","Esb-DebugResult", xmlРезультат.Закрыть());
	РезультатОбработки.CorrelationId = CorrelationId;
	РезультатОбработки.ReplyTo = ReplyTo;
	
	Возврат РезультатОбработки;
	
КонецФункции

//Процедура - Записать значение переменной
//
//Параметры:
//	xmlРезультат - ЗаписьXML - результат 
//	текСтрока - СтрокаТаблицыЗначений - строка результата обработки
// 
Процедура ЗаписатьЗначениеПеременной(xmlРезультат, текСтрока)
	
	xmlРезультат.ЗаписатьНачалоЭлемента("variable");
	xmlРезультат.ЗаписатьАтрибут("name", 	XMLСтрока(текСтрока.ИмяПеременной));
	
	Попытка
		
		_XMLПредставление = XMLСтрока(текСтрока.ЗначениеПеременной);
		
	Исключение
		
		_XMLПредставление = "";
		
	КонецПопытки;
	
	xmlРезультат.ЗаписатьАтрибут("value", _XMLПредставление);
	xmlРезультат.ЗаписатьАтрибут("type", Строка(текСтрока.ТипПеременной));
	
	Если ТипЗнч(текСтрока.ВложенныеЗначения) = Тип("Массив") И текСтрока.ВложенныеЗначения.Количество() > 0 Тогда
		
		xmlРезультат.ЗаписатьНачалоЭлемента("containsvalues");
		
		Для Каждого ЭлементМассива Из текСтрока.ВложенныеЗначения Цикл
			
			ЗаписатьЗначениеПеременной(xmlРезультат, ЭлементМассива);
			
		КонецЦикла;
		
		xmlРезультат.ЗаписатьКонецЭлемента();
		
	КонецЕсли;
	
	xmlРезультат.ЗаписатьКонецЭлемента();
	
КонецПроцедуры

//Функция - Выполнить поиск объекта отладки
//
//Параметры:
//	_сшп_Код - Строка - выполняемый код
//
//Возвращаемое значение:
//	- ЛюбоеЗначение - Значение для отладки обработки
//
Функция ВыполнитьПоискОбъектаОтладки(_сшп_Код)
	
	ОбъектОбработки = Неопределено;
	
	Выполнить(_сшп_Код);
	
	Возврат ОбъектОбработки;
	
КонецФункции

//Функция - Выполнить код отладки исходящий
//
//Параметры:
//	_сшп_Код - Строка - код для выполнения
//  _сшп_НомерСтроки - число - номер строки
//  _сшп_РезультатОтладки - ТаблицаЗначений - результаты отладки
//  ОбъектОбработки - ЛюбоеЗначение - обрабатываемый объект отладки
//  ФорматСообщения - ПеречислениеСсылка.сшпФорматыСообщений - формат сообщения
//  СостояниеСообщения - ПеречислениеСсылка.сшпСтатусыСообщений - состояние сообщения
//  сшп_МассивЗамеров - Массив - массив с замерами
//
//Возвращаемое значение:
//	Структура - заполненная структура пакета
//
функция ВыполнитьКодОтладкиИсходящий(_сшп_Код, _сшп_НомерСтроки, _сшп_РезультатОтладки, ОбъектОбработки, ФорматСообщения, СостояниеСообщения, сшп_МассивЗамеров)
	
	ЭтоУдаление = Ложь;
	ДатаРегистрации = ТекущаяДата();
	РезультатОбработки = сшпОбщегоНазначения.СформироватьСтруктуруПакета();
	Задержка = 0;
	Идентификатор = Новый УникальныйИдентификатор();
	РезультатОбработки.Id = Идентификатор;

	Выполнить(_сшп_Код);
	
	Возврат РезультатОбработки;
	
КонецФункции

//Процедура - Выполнить код отладки входящий
//
//Параметры:
//	_сшп_Код - Строка - код для выполнения
//  _сшп_НомерСтроки - число - номер строки
//  _сшп_РезультатОтладки - ТаблицаЗначений - результаты отладки
//  ОбъектСообщение - ОбъектXDTO - сообщение
//  ФорматСообщения - ПеречислениеСсылка.сшпФорматыСообщений - формат сообщения
//  СостояниеСообщения - ПеречислениеСсылка.сшпСтатусыСообщений - состояние сообщения
//  сшп_МассивЗамеров - Массив - массив с замерами
//	
Процедура ВыполнитьКодОтладкиВходящий(_сшп_Код, _сшп_НомерСтроки, _сшп_РезультатОтладки, ОбъектСообщение, ФорматСообщения, СостояниеСообщения, сшп_МассивЗамеров)
	
	ДатаРегистрации = ТекущаяДата();
	Задержка = 0;
	Идентификатор = ОбъектСообщение.Id;

	Выполнить(_сшп_Код);
	
КонецПроцедуры

//Процедура - Добавить значение переменной
//Поддерживаемые типы:
//	- Структура
//	- Соответствие
//  - Массив
//  - ФиксированноеСоответствие
//  - ФиксированнаяСтруктура
//	- ФиксированныйМассив
//	- ТаблицаЗначений
//	- Строка, Число, Булево, Дата
//	- ОбъектXDTO
//	- ДокументСсылка, ДокументОбъект
//	- СправочникСсылка, СправочникОбъект
//	- СписокЗначений
//	- Запрос
//	- РезультатЗапроса
//	- ВыборкаИзРезультатаЗапроса
//Остальное преобразуется в строку, либо не отображается
//
//Параметры:
//	_сшп_РезультатОтладки - ТаблицаЗначений - Возвращаемая ТаблицаЗначений с результатами отладки
//	ИмяПеременной - Строка - Имя обрабатываемой переменной
//	НомерСтроки - Число - номер обрабатываемой строки кода
//	_сшп_рез - Любой тип - значение переменной
//
Процедура ДобавитьЗначениеПеременной(_сшп_РезультатОтладки, ИмяПеременной, НомерСтроки, _сшп_рез)
	
	_сшп_новСтр = _сшп_РезультатОтладки.Добавить(); 
	_сшп_новСтр.ИмяПеременной = ИмяПеременной;
	_сшп_новСтр.НомерСтроки = НомерСтроки; 
	_сшп_новСтр.ПеременнаяНеОпределена = _сшп_рез = Null;
	
	Если Не _сшп_новСтр.ПеременнаяНеОпределена = Истина Тогда 
		
		_сшп_ТипПеременной = ТипЗнч(_сшп_рез); 
		_сшп_новСтр.ТипПеременной = _сшп_ТипПеременной; 
		
		Если _сшп_ТипПеременной = Тип("Структура") Или 
			_сшп_ТипПеременной = Тип("ФиксированнаяСтруктура") Или
			_сшп_ТипПеременной = Тип("Соответствие") Или
			_сшп_ТипПеременной = Тип("ФиксированноеСоответствие") Тогда 
			
			_сшп_ВложенныеЗначения = Новый Массив; 
			
			Для Каждого сшп_Элемент Из _сшп_рез Цикл 
				
				_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
				_сшп_ВложенноеЗначение.ИмяПеременной = сшп_Элемент.Ключ; 
				_сшп_ВложенноеЗначение.ЗначениеПеременной = сшп_Элемент.Значение; 
				_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_сшп_ВложенноеЗначение.ЗначениеПеременной); 
				
				Если Не (_сшп_ВложенноеЗначение.ТипПеременной = Тип("Строка") Или 
					_сшп_ВложенноеЗначение.ТипПеременной = Тип("Число") Или 
					_сшп_ВложенноеЗначение.ТипПеременной = Тип("Булево") Или 
					_сшп_ВложенноеЗначение.ТипПеременной = Тип("Дата")) Тогда 
					
					_сшп_ВложенноеЗначение.ЗначениеПеременной = Строка(_сшп_ВложенноеЗначение.ЗначениеПеременной); 
					
				КонецЕсли; 
				
				_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение); 
				
			КонецЦикла; 
			
			_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения; 
			_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 
			
		ИначеЕсли _сшп_ТипПеременной = Тип("Массив") Или 
			_сшп_ТипПеременной = Тип("ФиксированныйМассив") Тогда	
			
			_сшп_ВложенныеЗначения = Новый Массив; 
			
			Для _сшп_Индекс = 0 По _сшп_рез.Количество()-1 Цикл 
				
				_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
				_сшп_ВложенноеЗначение.ИмяПеременной = "[" + _сшп_Индекс + "]"; _сшп_ВложенноеЗначение.ЗначениеПеременной = _сшп_рез[_сшп_Индекс]; 
				_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_сшп_ВложенноеЗначение.ЗначениеПеременной); 
				
				Если Не (_сшп_ВложенноеЗначение.ТипПеременной = Тип("Строка") Или 
					_сшп_ВложенноеЗначение.ТипПеременной = Тип("Число") Или 
					_сшп_ВложенноеЗначение.ТипПеременной = Тип("Булево") Или 
					_сшп_ВложенноеЗначение.ТипПеременной = Тип("Дата")) Тогда 
					
					_сшп_ВложенноеЗначение.ЗначениеПеременной = Строка(_сшп_ВложенноеЗначение.ЗначениеПеременной); 
					
				КонецЕсли; 
				
				_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение); 
				
			КонецЦикла; 
			
			_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения; 
			_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 
			
		ИначеЕсли _сшп_ТипПеременной = Тип("ТаблицаЗначений") Тогда 
			
			_сшп_ВложенныеЗначения = Новый Массив;	
			
			Для Каждого _сшп_СтрокаТЧ Из _сшп_рез Цикл 
				
				_сшп_ИндексСтрокиТЧ = _сшп_рез.Индекс(_сшп_СтрокаТЧ); 
				_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
				_сшп_ВложенноеЗначение.ИмяПеременной ="[" + _сшп_ИндексСтрокиТЧ + "]"; 
				_сшп_ВложенноеЗначение.ЗначениеПеременной = _сшп_ИндексСтрокиТЧ; 
				_сшп_ВложенныеЗначения2 = Новый Массив;	
				
				Для Каждого _сшп_Колонка Из _сшп_рез.Колонки Цикл 
					
					_сшп_ВложенноеЗначение2 = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
					_сшп_ВложенноеЗначение2.ИмяПеременной = _сшп_Колонка.Имя; 
					_сшп_ВложенноеЗначение2.ЗначениеПеременной = _сшп_СтрокаТЧ[_сшп_Колонка.Имя]; 
					_сшп_ВложенноеЗначение2.ТипПеременной = ТипЗнч(_сшп_ВложенноеЗначение2.ЗначениеПеременной); 
					
					Если Не (_сшп_ВложенноеЗначение2.ТипПеременной = Тип("Строка") Или 
						_сшп_ВложенноеЗначение2.ТипПеременной = Тип("Число") Или 
						_сшп_ВложенноеЗначение2.ТипПеременной = Тип("Булево") Или 
						_сшп_ВложенноеЗначение2.ТипПеременной = Тип("Дата")) Тогда 
						
						_сшп_ВложенноеЗначение2.ЗначениеПеременной = Строка(_сшп_ВложенноеЗначение2.ЗначениеПеременной); 
						
					КонецЕсли;	
					
					_сшп_ВложенныеЗначения2.Добавить(_сшп_ВложенноеЗначение2); 
					
				КонецЦикла; 
				
				_сшп_ВложенноеЗначение.ВложенныеЗначения = _сшп_ВложенныеЗначения2; 
				_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение); 
				
			КонецЦикла; 
			
			_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения; 
			_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 
			
		ИначеЕсли _сшп_ТипПеременной = Тип("Строка") Или 
			_сшп_ТипПеременной = Тип("Число") Или 
			_сшп_ТипПеременной = Тип("Булево") Или 
			_сшп_ТипПеременной = Тип("Дата") Тогда 
			
			_сшп_новСтр.ЗначениеПеременной = _сшп_рез;

		ИначеЕсли _сшп_ТипПеременной = Тип("ОбъектXDTO") Тогда
						
			_сшп_ВложенныеЗначения = Новый Массив;
			
			Для Каждого _сшп_СтрокаТЧ Из _сшп_рез.Свойства() Цикл 
				 
				_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
				_сшп_ВложенноеЗначение.ИмяПеременной ="[" + _сшп_СтрокаТЧ.Имя + "]"; 
				_сшп_ВложенноеЗначение.ЗначениеПеременной = _сшп_рез[_сшп_СтрокаТЧ.Имя];
				_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_сшп_ВложенноеЗначение.ЗначениеПеременной); 
				_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение);
				
			КонецЦикла;
			
			_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения; 
			_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 			
			
		ИначеЕсли _сшп_ТипПеременной = Тип("СписокЗначений") Тогда
			        
			_сшп_ВложенныеЗначения = Новый Массив;
						
			Сч = 1;
			
			Для Каждого _сшп_СтрокаСписка Из _сшп_рез Цикл
				
				_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
				_сшп_ВложенноеЗначение.ИмяПеременной ="[" + Строка(Сч) + "]"; 
				_сшп_ВложенноеЗначение.ЗначениеПеременной = _сшп_СтрокаСписка.Значение;
				_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_сшп_СтрокаСписка.Значение); 
				_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение);				
				
				Сч = Сч + 1;
				
			КонецЦикла;
			
			_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения; 
			_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 
			
			
		ИначеЕсли _сшп_ТипПеременной = Тип("Запрос") Тогда
			
			ОписаниеСвойствОбъекта = Новый Массив;
			ОписаниеСвойствОбъекта.Добавить("МенеджерВременныхТаблиц");
			ОписаниеСвойствОбъекта.Добавить("Параметры");
			ОписаниеСвойствОбъекта.Добавить("Текст");
			
			_сшп_ВложенныеЗначения = Новый Массив;
			
			Для Сч = 0 По ОписаниеСвойствОбъекта.Количество()-1 Цикл
				
				_ЗначениеСвойства = _сшп_рез[ОписаниеСвойствОбъекта[Сч]];
				
				_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
				_сшп_ВложенноеЗначение.ИмяПеременной ="[" + ОписаниеСвойствОбъекта[Сч] + "]"; 
				_сшп_ВложенноеЗначение.ЗначениеПеременной = _ЗначениеСвойства;
				_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_ЗначениеСвойства); 
				
				Если ТипЗнч(_ЗначениеСвойства) = Тип("Структура") Тогда
					
					_сшп_ВложенноеЗначение.ВложенныеЗначения = Новый Массив();
					
					Для Каждого сшп_Элемент Из _ЗначениеСвойства Цикл 
						
						_сшп_ВложенноеЗначение2 = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
						_сшп_ВложенноеЗначение2.ИмяПеременной = сшп_Элемент.Ключ; 
						_сшп_ВложенноеЗначение2.ЗначениеПеременной = сшп_Элемент.Значение; 
						_сшп_ВложенноеЗначение2.ТипПеременной = ТипЗнч(_сшп_ВложенноеЗначение2.ЗначениеПеременной); 
						
						Если Не (_сшп_ВложенноеЗначение2.ТипПеременной = Тип("Строка") Или 
							_сшп_ВложенноеЗначение2.ТипПеременной = Тип("Число") Или 
							_сшп_ВложенноеЗначение2.ТипПеременной = Тип("Булево") Или 
							_сшп_ВложенноеЗначение2.ТипПеременной = Тип("Дата")) Тогда 
							
							_сшп_ВложенноеЗначение2.ЗначениеПеременной = Строка(_сшп_ВложенноеЗначение2.ЗначениеПеременной); 
							
						КонецЕсли; 
						
						_сшп_ВложенноеЗначение.ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение2); 
						
					КонецЦикла;
					
				КонецЕсли;
				
				_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение);				
								
			КонецЦикла;
			
			_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения; 
			_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 			
			
		ИначеЕсли _сшп_ТипПеременной = Тип("РезультатЗапроса") Тогда
						
			_сшп_ВложенныеЗначения = Новый Массив;
			
			Для Каждого _сшп_СтрокаКолонок Из _сшп_рез.Колонки Цикл
				
				_ЗначениеСвойства = _сшп_СтрокаКолонок.Имя;
				
				_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
				_сшп_ВложенноеЗначение.ИмяПеременной ="[Колонка]"; 
				_сшп_ВложенноеЗначение.ЗначениеПеременной = _ЗначениеСвойства;
				_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_сшп_СтрокаКолонок); 				
				_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение);				
								
			КонецЦикла;
			
			_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения; 
			_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез);	
			
		ИначеЕсли _сшп_ТипПеременной = Тип("ВыборкаИзРезультатаЗапроса") Тогда
			
			_сшп_ВложенныеЗначения = Новый Массив;
			
			Для Каждого _сшп_СтрокаКолонок Из _сшп_рез.Владелец().Колонки Цикл
				
				_ЗначениеСвойства = _сшп_рез[_сшп_СтрокаКолонок.Имя];
				
				_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
				_сшп_ВложенноеЗначение.ИмяПеременной ="[" + _сшп_СтрокаКолонок.Имя + "]"; 
				_сшп_ВложенноеЗначение.ЗначениеПеременной = Строка(_ЗначениеСвойства);
				_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_ЗначениеСвойства); 				
				_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение);
				
			КонецЦикла;
			
			_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения; 
			_сшп_новСтр.ЗначениеПеременной = "";
			
		ИначеЕсли Не XMLТипЗнч(_сшп_рез) = Неопределено Тогда 
			
			_сшп_ТипXML = XMLТипЗнч(_сшп_рез).ИмяТипа;	
			
			Если СтрНайти(_сшп_ТипXML, "Ref") > 0 Или СтрНайти(_сшп_ТипXML, "Object") > 0 Тогда
				
				ТипМетаданных = "";	
				
				Если СтрНайти(_сшп_ТипXML, "CatalogRef.") > 0 Тогда 
					
					ИмяМетаданных = Сред(_сшп_ТипXML,СтрДлина("CatalogRef.")+1); 
					ТипМетаданных = "Справочники";	
					
				ИначеЕсли СтрНайти(_сшп_ТипXML, "CatalogObject.") > 0 Тогда 
					
					ИмяМетаданных = Сред(_сшп_ТипXML,СтрДлина("CatalogObject.")+1); 
					ТипМетаданных = "Справочники"; 
					
				ИначеЕсли СтрНайти(_сшп_ТипXML, "DocumentRef.") > 0 Тогда 
					
					ИмяМетаданных = Сред(_сшп_ТипXML,СтрДлина("DocumentRef.")+1); 
					ТипМетаданных = "Документы"; 
					
				ИначеЕсли СтрНайти(_сшп_ТипXML, "DocumentObject.") > 0 Тогда 
					
					ИмяМетаданных = Сред(_сшп_ТипXML,СтрДлина("DocumentObject.")+1); 
					ТипМетаданных = "Документы"; 
					
				КонецЕсли; 
				
				Если Не ТипМетаданных = "" И Не Метаданные[ТипМетаданных].Найти(ИмяМетаданных) = Неопределено Тогда 
					
					_сшп_ВложенныеЗначения = Новый Массив; 
					_сшп_Метаданные = _сшп_рез.Метаданные();	
					
					Для Каждого _сшп_Реквизит Из _сшп_Метаданные.СтандартныеРеквизиты Цикл 
						
						_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
						_сшп_ВложенноеЗначение.ИмяПеременной = _сшп_Реквизит.Имя; 
						_сшп_ВложенноеЗначение.ЗначениеПеременной = _сшп_рез[_сшп_Реквизит.Имя]; 
						_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_сшп_ВложенноеЗначение.ЗначениеПеременной); 
						
						Если Не (_сшп_ВложенноеЗначение.ТипПеременной = Тип("Строка") Или 
							_сшп_ВложенноеЗначение.ТипПеременной = Тип("Число") Или 
							_сшп_ВложенноеЗначение.ТипПеременной = Тип("Булево") Или 
							_сшп_ВложенноеЗначение.ТипПеременной = Тип("Дата")) Тогда 
							
							_сшп_ВложенноеЗначение.ЗначениеПеременной = Строка(_сшп_ВложенноеЗначение.ЗначениеПеременной); 
							
						КонецЕсли; 
						
						_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение); 
						
					КонецЦикла; 
					
					Для Каждого _сшп_Реквизит Из _сшп_Метаданные.Реквизиты Цикл 
						
						_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
						_сшп_ВложенноеЗначение.ИмяПеременной = _сшп_Реквизит.Имя; 
						_сшп_ВложенноеЗначение.ЗначениеПеременной = _сшп_рез[_сшп_Реквизит.Имя];
						_сшп_ВложенноеЗначение.ТипПеременной = ТипЗнч(_сшп_ВложенноеЗначение.ЗначениеПеременной);
						
						Если Не (_сшп_ВложенноеЗначение.ТипПеременной = Тип("Строка") Или 
							_сшп_ВложенноеЗначение.ТипПеременной = Тип("Число") Или 
							_сшп_ВложенноеЗначение.ТипПеременной = Тип("Булево") Или 
							_сшп_ВложенноеЗначение.ТипПеременной = Тип("Дата")) Тогда 
							
							_сшп_ВложенноеЗначение.ЗначениеПеременной = Строка(_сшп_ВложенноеЗначение.ЗначениеПеременной); 
							
						КонецЕсли; 
						
						_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение); 
						
					КонецЦикла; 
					
					Для Каждого _сшп_ТабличнаяЧасть Из _сшп_Метаданные.ТабличныеЧасти Цикл 
						
						_сшп_ВложенноеЗначение = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
						_сшп_ВложенноеЗначение.ИмяПеременной = _сшп_ТабличнаяЧасть.Имя; 
						_сшп_ВложенноеЗначение.ЗначениеПеременной = Неопределено; 
						_сшп_ВложенноеЗначение.ТипПеременной = "ТабличнаяЧасть"; 
						_сшп_ВложенныеЗначения2 = Новый Массив; 
						
						Для Каждого _сшп_СтрокаТЧ Из _сшп_рез[_сшп_ТабличнаяЧасть.Имя] Цикл 
							
							_сшп_ВложенноеЗначение2 = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
							_сшп_ВложенноеЗначение2.ИмяПеременной = "[" + _сшп_СтрокаТЧ.НомерСтроки + "]"; 
							_сшп_ВложенноеЗначение2.ЗначениеПеременной = _сшп_СтрокаТЧ.НомерСтроки; 
							_сшп_ВложенныеЗначения3 = Новый Массив; 
							
							Для Каждого _сшп_Колонка Из _сшп_Метаданные.ТабличныеЧасти[_сшп_ТабличнаяЧасть.Имя].Реквизиты Цикл	
								
								_сшп_ВложенноеЗначение3 = Новый Структура("ИмяПеременной, ЗначениеПеременной, ТипПеременной, ВложенныеЗначения"); 
								_сшп_ВложенноеЗначение3.ИмяПеременной = _сшп_Колонка.Имя; 
								_сшп_ВложенноеЗначение3.ЗначениеПеременной = _сшп_СтрокаТЧ[_сшп_Колонка.Имя]; 
								_сшп_ВложенноеЗначение3.ТипПеременной = ТипЗнч(_сшп_ВложенноеЗначение3.ЗначениеПеременной); 
								
								Если Не (_сшп_ВложенноеЗначение3.ТипПеременной = Тип("Строка") Или 
									_сшп_ВложенноеЗначение3.ТипПеременной = Тип("Число") Или 
									_сшп_ВложенноеЗначение3.ТипПеременной = Тип("Булево") Или 
									_сшп_ВложенноеЗначение3.ТипПеременной = Тип("Дата")) Тогда 
									
									_сшп_ВложенноеЗначение3.ЗначениеПеременной = Строка(_сшп_ВложенноеЗначение3.ЗначениеПеременной); 
									
								КонецЕсли; _сшп_ВложенныеЗначения3.Добавить(_сшп_ВложенноеЗначение3); 
								
							КонецЦикла; 
							
							_сшп_ВложенноеЗначение2.ВложенныеЗначения = _сшп_ВложенныеЗначения3; 
							_сшп_ВложенныеЗначения2.Добавить(_сшп_ВложенноеЗначение2); 
							
						КонецЦикла;; 
						
						_сшп_ВложенноеЗначение.ВложенныеЗначения = _сшп_ВложенныеЗначения2; 
						_сшп_ВложенныеЗначения.Добавить(_сшп_ВложенноеЗначение); 
						
					КонецЦикла; 
					
					_сшп_новСтр.ВложенныеЗначения = _сшп_ВложенныеЗначения;	
					
				Иначе 
					
					Попытка
						_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 
					Исключение
						_сшп_новСтр.ЗначениеПеременной = "";
					КонецПопытки;
					
				КонецЕсли; 
				
			Иначе 
				
				Попытка
					_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 
				Исключение
					_сшп_новСтр.ЗначениеПеременной = "";
				КонецПопытки;
				
			КонецЕсли;	
			
		Иначе 
			
			Попытка
				_сшп_новСтр.ЗначениеПеременной = Строка(_сшп_рез); 
			Исключение
				_сшп_новСтр.ЗначениеПеременной = "";
			КонецПопытки;			
			
		КонецЕсли; 
		
	КонецЕсли;
	
КонецПроцедуры

// Функция - Начать замер времени
// 
// Возвращаемое значение:
// 	Число - Текущая универсальная дата в микросекундах или 0, если используется компонента
//
Функция НачатьЗамерВремени() Экспорт 
	
	_ЭкземплярКомпоненты = сшпКэшируемыеФункции.ПолучитьКомпоненту();
	
	Если _ЭкземплярКомпоненты = Неопределено Тогда
		
		Возврат ТекущаяУниверсальнаяДатаВМиллисекундах() * 1000;
		
	Иначе
		
		_ЭкземплярКомпоненты.StartTimer(180000000);	
		
		Возврат 0;
		
	КонецЕсли;
	
КонецФункции

// Функция - Получить время выполнения
// 
// Параметры:
// 	_НачалоЗамера - Число - Время начала замера в микросекундах
// Возвращаемое значение:
// 	Число - Время выполнения в микросекундах
Функция ПолучитьВремяВыполнения(_НачалоЗамера = 0) Экспорт 
	
	_ЭкземплярКомпоненты = сшпКэшируемыеФункции.ПолучитьКомпоненту();
	
	Если _ЭкземплярКомпоненты = Неопределено Тогда
		
		Возврат ТекущаяУниверсальнаяДатаВМиллисекундах() * 1000 - _НачалоЗамера;
		
	Иначе
		
		Возврат _ЭкземплярКомпоненты.GetTimerRemainder();
		
	КонецЕсли;
	
КонецФункции