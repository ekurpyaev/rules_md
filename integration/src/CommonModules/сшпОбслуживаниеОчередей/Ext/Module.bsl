﻿
#Область ПроцедурыИФункцииМодуля
//
// Процедура - Управление пулом обработчиков
//
Процедура УправлениеПуломОбработчиков() Экспорт
	
	сшпОбновлениеВерсииКонфигурации.ВыполнитьОбновлениеДанныхКонфигурации();
	
	Если ПолучитьФункциональнуюОпцию("сшпИспользоватьСШП") И Не ПолучитьФункциональнуюОпцию("сшпОтключитьПотоки") Тогда
		
		Если Не сшпОбщегоНазначения.ПроверитьЭкземплярИнформационнойБазы() Тогда
			
			ЗаписьЖурналаРегистрации("Datareon. Управление пулом обработчиков", УровеньЖурналаРегистрации.Ошибка, , , "Рассинхронизация идентификаторов информационной базы");
			
			Возврат;
		
		КонецЕсли;
		
		Если Не сшпРаботаСКонстантами.ТипКоннектораВебСервисы() Тогда 
			
			Возврат;
		
		КонецЕсли;

		// Предварительная очистка от накопившегося мусора
		сшпОбщегоНазначения.ЗапуститьОбработчикОчереди("ОчисткаОчередейСообщений");		
		сшпОбщегоНазначения.ЗапуститьОбработчикОчереди("ОбработкаОчередиИсходящихСообщений");
	
	КонецЕсли;

КонецПроцедуры
	
// Процедура - Обработка очереди исходящих сообщений
//
Процедура ОбработкаОчередиИсходящихСообщений() Экспорт
	
	Если сшпФункциональныеОпции.ТипИспользуемогоКоннектораESB() = Перечисления.сшпТипыКоннекторовESB.Pipe ИЛИ
		сшпФункциональныеОпции.ТипИспользуемогоКоннектораESB() = Перечисления.сшпТипыКоннекторовESB.Tcp Тогда 
		
		Возврат;
	
	КонецЕсли;
	
	Если Не сшпОбщегоНазначения.ПроверитьЭкземплярИнформационнойБазы() Тогда
		
		ЗаписьЖурналаРегистрации("Datareon. Управление пулом обработчиков", УровеньЖурналаРегистрации.Ошибка, , , "Рассинхронизация идентификаторов информационной базы");
		
		Возврат;
	
	КонецЕсли;
	
	ИспользоватьПакетныйРежим = сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты("сшпРежимПередачиСообщений") = Перечисления.сшпРежимыПередачиСообщений.Batch;
	РазмерПакета = сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты("сшпРазмерПакета");
	КоличествоСообщений = ?(ИспользоватьПакетныйРежим, Макс(РазмерПакета, 1), 10);
	
	МассивПараметров = Новый Массив();
	
	ВремяОжидания = ?(сшпФункциональныеОпции.АвтоматическийСтартОбработчиков(), сшпКэшируемыеФункции.ДлительностьОжиданияПриАвтоматическомСтарте(), сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты("сшпДлительностьОжидания")) * 1000;
	ОстатокВремениОжидания = времяОжидания;
	МаксимумПотоков = сшпРаботаСКонстантами.ПолучитьЗначениеКонстанты("сшпМаксимальноеКоличествоПотоковОбработкиИсходящих");
	
	Пока ОстатокВремениОжидания > 0 Цикл
		
		СтартОжидания = ТекущаяУниверсальнаяДатаВМиллисекундах();
		
		Если Не ПолучитьФункциональнуюОпцию("сшпИспользоватьСШП") Или ПолучитьФункциональнуюОпцию("сшпОтключитьПотоки") Или ПолучитьФункциональнуюОпцию("сшпОтключитьПотокОбработкиОчередиИсходящих") Тогда
			
			Прервать;
		
		ИначеЕсли ИдетОбработкаСистемныхСобытий() Тогда //Если включена обработка системных событий приостанавливаем рабочие потоки обработки
			
			сшпОбщегоНазначения.Ожидание(1);
			
			Продолжить;
		
		КонецЕсли;
		
		ТекКоличествоПотоков = МаксимумПотоков - сшпОбщегоНазначения.ПолучитьКоличествоПотоков("Наименование", "СформироватьИсходящееСообщение");
		
		Если ТекКоличествоПотоков > 0 Тогда
			
			ТекЗапрос = Новый Запрос("ВЫБРАТЬ ПЕРВЫЕ " + ?(Не ИспользоватьПакетныйРежим, Формат(ТекКоличествоПотоков, "ЧГ=0;"), Формат(КоличествоСообщений,"ЧГ=0;")) + "
			|	тбОчередь.ИдентификаторСобытия,
			|	тбСостояние.ИдентификаторСообщения,
			|	тбОчередь.ДатаРегистрации,
			|	тбОчередь.ФорматСообщения,
			|	тбОчередь.МетодХранения,
			|	тбОчередь.ЭтоУдаление,
			|	тбОчередь.ОбъектСобытия,
			|	тбОчередь.СсылкаНаОбъект
			|ИЗ
			|	РегистрСведений.сшпОчередьИсходящихСообщений КАК тбОчередь
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.сшпСостояниеСообщений КАК тбСостояние
			|		ПО тбОчередь.ИдентификаторСобытия = тбСостояние.ИдентификаторСобытия
			|			И (тбСостояние.СтатусСообщения  В (&СписокСтатусов))
			|			И тбСостояние.ЗадержкаЧисло <= &ЗадержкаЧисло
			|
			|УПОРЯДОЧИТЬ ПО
			|	тбСостояние.ДатаИзменения");
			ТекЗапрос.УстановитьПараметр("СписокСтатусов", сшпКэшируемыеФункции.ПоучитьСписокРабочихСтатусов());
			ТекЗапрос.УстановитьПараметр("ЗадержкаЧисло", сшпОбщегоНазначения.ПеревестиДатуВЧисло(ТекущаяДатаСеанса()));
			
			ТекРезультат = ТекЗапрос.Выполнить();
			
			Если ТекРезультат.Пустой() Тогда
				
				сшпОбщегоНазначения.Ожидание(1);
				ОстатокВремениОжидания = ОстатокВремениОжидания - (ТекущаяУниверсальнаяДатаВМиллисекундах() - СтартОжидания);
			
			Иначе
				
				ТекИдентификатор = "Идентификатор не определен";
				МассивПараметров.Очистить();
				Индекс = 0;
				
				Попытка
					
					ТекВыборка = ТекРезультат.Выбрать();
					
					Пока текВыборка.Следующий() Цикл
												
						ТекИдентификатор = ТекВыборка.ИдентификаторСообщения;
						сшпРаботаСДанными.УстановитьСостояниеСообщения(ТекИдентификатор, Перечисления.сшпСтатусыСообщений.ВОбработке, , , , , Перечисления.сшпТипыИнтеграции.Исходящая);
						
						МсвПараметры = Новый Массив;
						МсвПараметры.Добавить(ТекИдентификатор);
						МсвПараметры.Добавить(ТекВыборка.ИдентификаторСобытия);
						МсвПараметры.Добавить(ТекВыборка.ФорматСообщения);
						МсвПараметры.Добавить(ТекВыборка.ОбъектСобытия);
						МсвПараметры.Добавить(ТекВыборка.МетодХранения);
						МсвПараметры.Добавить(ТекВыборка.ДатаРегистрации);
						МсвПараметры.Добавить(ТекВыборка.ЭтоУдаление);
						МсвПараметры.Добавить(ТекВыборка.СсылкаНаОбъект);
						
						Если ИспользоватьПакетныйРежим Тогда
							
							Индекс = Индекс + 1;
							
							МассивПараметров.Добавить(МсвПараметры);
							 						
							Если Индекс >= КоличествоСообщений Тогда
								
								ВложенныйМассивПараметров = Новый Массив();
								ВложенныйМассивПараметров.Добавить(МассивПараметров);
								
								ФоновыеЗадания.Выполнить("сшпОбслуживаниеОчередей.СформироватьИсходящиеСообщения", ВложенныйМассивПараметров, Новый УникальныйИдентификатор(), "СформироватьИсходящееСообщение");
								Индекс = 0;
								МассивПараметров.Очистить();
								
							КонецЕсли;
							
						Иначе
												
							ФоновыеЗадания.Выполнить("сшпОбслуживаниеОчередей.СформироватьИсходящееСообщение", МсвПараметры, ТекИдентификатор, "СформироватьИсходящееСообщение");
							
						КонецЕсли;
					
					КонецЦикла;
					
					Если МассивПараметров.Количество() Тогда
						
						ВложенныйМассивПараметров = Новый Массив();
						ВложенныйМассивПараметров.Добавить(МассивПараметров);
						
						ФоновыеЗадания.Выполнить("сшпОбслуживаниеОчередей.СформироватьИсходящиеСообщения", ВложенныйМассивПараметров, Новый УникальныйИдентификатор(), "СформироватьИсходящееСообщение");
						
					КонецЕсли;
					
					ОстатокВремениОжидания = ВремяОжидания;
					
				Исключение
					
					ИнформацияОбОшибке = ИнформацияОбОшибке();
					ЗаписьЖурналаРегистрации("Datareon. Обработка очереди исходящих сообщений", УровеньЖурналаРегистрации.Ошибка,, ТекИдентификатор, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
				
				КонецПопытки;
				
			КонецЕсли;
				
		КонецЕсли;
		
	КонецЦикла;
		
КонецПроцедуры

// Процедура - Сформировать исходящие сообщения
//
// Параметры:
// МассивСообщений - Массив - Массив параметров сообщений
// 
Процедура СформироватьИсходящиеСообщения(МассивСообщений) Экспорт
	
	Если ИдетОбработкаСистемныхСобытий() Тогда
		
		Возврат; //Если включена обработка системных событий останавливаем рабочие потоки.
		
	КонецЕсли;
	
	МассивДляОтправкиСообщений = Новый Массив();
		
	Для Сч = 0 По МассивСообщений.Количество()-1 Цикл
		
		Идентификатор = МассивСообщений[Сч][0];
		ИдентификаторСобытия = МассивСообщений[Сч][1];
		ФорматСообщения = МассивСообщений[Сч][2];
		ТипОбъекта = МассивСообщений[Сч][3];
		МетодХранения = МассивСообщений[Сч][4];
		ДатаРегистрации = МассивСообщений[Сч][5];
		ЭтоУдаление = МассивСообщений[Сч][6];
		СсылкаНаОбъект = МассивСообщений[Сч][7];
		
		НовыйСтатус = сшпОбщегоНазначения.ПолучитьСтатусСобытия(ИдентификаторСобытия);
		Если НовыйСтатус = Перечисления.сшпСтатусыСообщений.ПакетнаяОбработка Тогда
			Продолжить;
		КонецЕсли;
		
		СткОбработчик = сшпКэшируемыеФункции.ПолучитьОбработчик(Типобъекта, Перечисления.сшпТипыИнтеграции.Исходящая, сшпФункциональныеОпции.ВерсияОбработчиков());
				
		Если Не ЗначениеЗаполнено(СткОбработчик.ПроцедураОбработки) Тогда
			
			сшпРаботаСДанными.УстановитьСостояниеСообщения(ИдентификаторСобытия, Перечисления.сшпСтатусыСообщений.ОтсутствуетОбработчик, ,"В 1С отсутствует исходящий обработчик для " + Строка(ТипОбъекта) , , , Перечисления.сшпТипыИнтеграции.Исходящая);
			
		Иначе	
			
			Если СткОбработчик.Статус = Перечисления.сшпСтатусыОбработчиков.Отключен Тогда
				
				сшпРаботаСДанными.УстановитьСостояниеСообщения(ИдентификаторСобытия, Перечисления.сшпСтатусыСообщений.ОбработкаОтменена, ,"Обработка исходящего сообщения была отменена! Обработчик отключен!" , , , Перечисления.сшпТипыИнтеграции.Исходящая);
				
			Иначе
				
				Задержка = 0;
				ОписаниеОшибки = "";
				ОтменитьОтправку = Ложь;
				ТекЗаголовокЖурнала = "Datareon. Получение объекта события";
				ТекстОшибки = "";
				
				Объектсобытия = ПолучитьОбъектСобытия(Перечисления.сшпТипыИнтеграции.Исходящая, ИдентификаторСобытия);
				
				ТекЗаголовокЖурнала = "Datareon. Формирование сообщения";
				
				РезультатОбработки = сшпОбщегоНазначения.СформироватьСтруктуруПакета();
				РезультатОбработки.Id = Идентификатор;
				
				Попытка
					
					СостояниеСообщения = Перечисления.сшпСтатусыСообщений.Обработано;
					ОбъектОбработки = Неопределено;
					
					Если МетодХранения = Перечисления.сшпМетодХранения.ПоСсылке Тогда
						
						Если ТипЗнч(ОбъектСобытия) = Тип("Отбор") Тогда
							
							ТипРегистра = сшпКэшируемыеФункции.ПолучитьТипОбъекта(ТипОбъекта);
							ИмяРегистра = сшпКэшируемыеФункции.ПолучитьИмяОбъекта(ТипОбъекта);
							
							Если ТипРегистра = "РегистрСведений" Тогда
								
								ОбъектОбработки = РегистрыСведений[ИмяРегистра].СоздатьНаборЗаписей();	
								
							ИначеЕсли ТипРегистра = "РегистрНакопления" Тогда
								
								ОбъектОбработки = РегистрыНакопления[ИмяРегистра].СоздатьНаборЗаписей();
								
							ИначеЕсли ТипРегистра = "РегистрБухгалтерии" Тогда
								
								ОбъектОбработки = РегистрыБухгалтерии[ИмяРегистра].СоздатьНаборЗаписей();
								
							ИначеЕсли ТипРегистра = "РегистрРасчета" Тогда
								
								ОбъектОбработки = РегистрыРасчета[ИмяРегистра].СоздатьНаборЗаписей();
								
							Иначе
								
								ВызватьИсключение "Тип: " + ТипРегистра + " не поддерживается текущей версией подсистемы ESB";
								
							КонецЕсли;
							
							Для Каждого ЭлементОтбор Из ОбъектСобытия Цикл
								
								ЗаполнитьЗначенияСвойств(ОбъектОбработки.Отбор[ЭлементОтбор.Имя], ЭлементОтбор);
								
							КонецЦикла;
							
							ОбъектОбработки.Прочитать();
							
						Иначе
							
							ОбъектОбработки = ОбъектСобытия;
							
						КонецЕсли;
						
					Иначе
						
						ОбъектОбработки = сшпОбщегоНазначения.ДесериализоватьОбъект(ФорматСообщения, ОбъектСобытия);
						
					КонецЕсли;
					
					//++ Градум Гусев А.С. 05.05.2021
					ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле = ОценкаПроизводительности.НачатьЗамерВремени();
					//-- Градум Гусев А.С. 05.05.2021
					
					Выполнить(сткОбработчик.ПроцедураОбработки);
					
					//++ Градум Гусев А.С. 05.05.2021
					ОценкаПроизводительности.ЗакончитьЗамерВремени( грОбработкаПакетовИнтеграцииПовтИсп.ПолучитьПрефиксКлючевойОперации() 
							+ сткОбработчик.Наименование + " - общее время", ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле);
					//-- Градум Гусев А.С. 05.05.2021
				
					Если СостояниеСообщения = Перечисления.сшпСтатусыСообщений.Обработано Тогда
						
						сшпОбщегоНазначения.УстановитьСвойствоПоиска(СсылкаНаОбъект, РезультатОбработки);
						
						МассивДляОтправкиСообщений.Добавить(РезультатОбработки);
						
					КонецЕсли;
					
				Исключение
					
					ТекстОшибки = сшпОбщегоНазначения.ПолучитьТекстОшибкиОбработчика(ИнформацияОбОшибке());
					ЗаписьЖурналаРегистрации(текЗаголовокЖурнала, УровеньЖурналаРегистрации.Ошибка, , ИдентификаторСобытия, ТекстОшибки);
					
					//++ Градум Гусев А.С. 05.05.2021
					ДанныеДляКомментария = Новый Структура("ТекстОшибки", ТекстОшибки);
					ОценкаПроизводительности.ЗакончитьЗамерВремени( грОбработкаПакетовИнтеграцииПовтИсп.ПолучитьПрефиксКлючевойОперации() 
						+ сткОбработчик.Наименование + " - общее время, ошибка", ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле,, ДанныеДляКомментария);
					//-- Градум Гусев А.С. 05.05.2021
					
					Если текЗаголовокЖурнала = "Datareon. Формирование сообщения" Тогда
						
						СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
												
					Иначе
						
						СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
						Задержка = 30;
						
					КонецЕсли;
					
				КонецПопытки;
							
				Если Не СостояниеСообщения = Перечисления.сшпСтатусыСообщений.Обработано Тогда
					
					Если СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки Тогда
						ТекстОшибки = сшпОбщегоНазначения.ДополнитьТекстОшибки(ТекстОшибки, сткОбработчик, СсылкаНаОбъект);
					КонецЕсли;
					
					сшпРаботаСДанными.УстановитьСостояниеСообщения(ИдентификаторСобытия, СостояниеСообщения, Задержка, ТекстОшибки, , , Перечисления.сшпТипыИнтеграции.Исходящая, Типобъекта, Идентификатор);
				
				КонецЕсли;				
								
			КонецЕсли;
			
		КонецЕсли;	
		
	КонецЦикла;
	
	Если МассивДляОтправкиСообщений.Количество()>0 Тогда
		
		Коннектор = сшпВзаимодействиеСАдаптером.ПолучитьКоннектор();
		Если Коннектор = Неопределено Тогда
			
			Возврат;
			
		КонецЕсли;
				
		сшпОбслуживаниеОчередей.ОтправитьСообщение(Коннектор, МассивДляОтправкиСообщений);
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура - Отправить сообщение
//
// Параметры:
//  Коннектор - HTTPСоединение,WSПрокси - Соединение с адаптером.
//  Сообщение - Массив, Структура - структура, содержащая исходящее сообщение или массив структур.
//  ИзменятьСтатус - Булево - вызов метода УстановитьСостояниеСообщения
//
Процедура ОтправитьСообщение(Коннектор, Сообщение, ИзменятьСтатус = Истина) Экспорт 
	
	сшпВзаимодействиеСАдаптером.ОтправитьСообщениеНаАдаптер(Коннектор, Сообщение, ИзменятьСтатус);
	
	Если Коннектор = Неопределено Тогда 
		
		ЗаписьЖурналаРегистрации("Datareon. Взаимодействие с адаптером", УровеньЖурналаРегистрации.Предупреждение, , , "Отсутствует связь с адаптером");
	
	КонецЕсли;

КонецПроцедуры

// Процедура - Очистка очередей сообщений
//
Процедура ОчисткаОчередейСообщений() Экспорт
		
		//Возврат в обработку "зависших" сообщений
		ТекЗапрос = Новый Запрос("ВЫБРАТЬ
		|	тбОчередь.ИдентификаторСобытия КАК Идентификатор,
		|	ЗНАЧЕНИЕ(Перечисление.сшпТипыОчередей.Исходящая) КАК ТипОчереди
		|ИЗ
		|	РегистрСведений.сшпОчередьИсходящихСообщений КАК тбОчередь
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.сшпСостояниеСообщений КАК тбСостояние
		|		ПО тбОчередь.ИдентификаторСобытия = тбСостояние.ИдентификаторСобытия
		|		И (тбСостояние.СтатусСообщения = ЗНАЧЕНИЕ(Перечисление.сшпСтатусыСообщений.ВОбработке)
		|		И РАЗНОСТЬДАТ(тбСостояние.ДатаИзменения, &ТекущаяДата, МИНУТА) > 60
		|		ИЛИ тбСостояние.СтатусСообщения = ЗНАЧЕНИЕ(Перечисление.сшпСтатусыСообщений.Отправлено)
		|		И РАЗНОСТЬДАТ(тбСостояние.ДатаИзменения, &ТекущаяДата, МИНУТА) > 15
		|		ИЛИ тбСостояние.СтатусСообщения = ЗНАЧЕНИЕ(Перечисление.сшпСтатусыСообщений.Обработано)
		|		И РАЗНОСТЬДАТ(тбСостояние.ДатаИзменения, &ТекущаяДата, МИНУТА) > 30)");
		ТекЗапрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
		
		ТекВыборка = текЗапрос.Выполнить().Выбрать();
		
		Пока ТекВыборка.Следующий() Цикл
			
			Состояние = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
			сшпРаботаСДанными.УстановитьСостояниеСообщения(текВыборка.Идентификатор, Состояние, , , , , Перечисления.сшпТипыИнтеграции.Исходящая);
		
		КонецЦикла;
		
		//Очистка очереди от старых сообщений
		ТекЗапрос = Новый Запрос(
		"ВЫБРАТЬ
		|	ТаблицаДлительностиОжидания.ТипОчереди КАК ТипОчереди,
		|	ТаблицаДлительностиОжидания.СтатусСообщения КАК СтатусСообщения,
		|	ТаблицаДлительностиОжидания.ДлительностьХранения КАК Длительность
		|ПОМЕСТИТЬ ТаблицаДлительностиОжидания
		|ИЗ
		|	&ТаблицаДлительностиОжидания КАК ТаблицаДлительностиОжидания
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	тбОчередь.ИдентификаторСобытия КАК Идентификатор,
		|	ЗНАЧЕНИЕ(Перечисление.сшпТипыОчередей.Исходящая) КАК ТипОчереди
		|ИЗ
		|	РегистрСведений.сшпОчередьИсходящихСообщений КАК тбОчередь
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.сшпСостояниеСообщений КАК тбСостояние
		|			ЛЕВОЕ СОЕДИНЕНИЕ ТаблицаДлительностиОжидания КАК ТаблицаДлительностиОжидания
		|			ПО тбСостояние.СтатусСообщения = ТаблицаДлительностиОжидания.СтатусСообщения
		|				И (ЗНАЧЕНИЕ(Перечисление.сшпТипыОчередей.Исходящая) = ТаблицаДлительностиОжидания.ТипОчереди)
		|		ПО тбОчередь.ИдентификаторСобытия = тбСостояние.ИдентификаторСобытия
		|			И (РАЗНОСТЬДАТ(тбСостояние.ДатаИзменения, &ТекущаяДата, ДЕНЬ) > ЕСТЬNULL(ТаблицаДлительностиОжидания.Длительность, &СрокХраненияПоУмолчанию))
		|			И (ЕСТЬNULL(ТаблицаДлительностиОжидания.Длительность, &СрокХраненияПоУмолчанию) > 0)");
		ТекЗапрос.УстановитьПараметр("ТекущаяДата", ТекущаяДатаСеанса());
		ТекЗапрос.УстановитьПараметр("СрокХраненияПоУмолчанию", сшпРаботаСКонстантами.ПолучитьДлительностьХраненияПоУмолчанию());
		ТекЗапрос.УстановитьПараметр("ТаблицаДлительностиОжидания", сшпРаботаСКонстантами.ПолучитьДлительностьХранения());
		
		ТекВыборка = ТекЗапрос.Выполнить().Выбрать();
		
		Пока ТекВыборка.Следующий() Цикл
			
			сшпРаботаСДанными.УдалитьСообщение(ТекВыборка.ТипОчереди, ТекВыборка.Идентификатор);
		
		КонецЦикла;
						
		//Очистка очереди исходящих сообщений
		ТекЗапрос = Новый Запрос("ВЫБРАТЬ
		|	сшпОчередьИсходящихСообщений.ИдентификаторСобытия КАК Идентификатор
		|ИЗ
		|	РегистрСведений.сшпОчередьИсходящихСообщений КАК сшпОчередьИсходящихСообщений
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.сшпСостояниеСообщений КАК сшпСостояниеСообщений
		|		ПО сшпОчередьИсходящихСообщений.ИдентификаторСобытия = сшпСостояниеСообщений.ИдентификаторСобытия
		|		И сшпСостояниеСообщений.СтатусСообщения = ЗНАЧЕНИЕ(Перечисление.сшпСтатусыСообщений.ОтправкаПодтверждена)");
		
		ТекВыборка = ТекЗапрос.Выполнить().Выбрать();
		
		Пока ТекВыборка.Следующий() Цикл
			
			сшпРаботаСДанными.УдалитьСообщение(Перечисления.сшпТипыОчередей.Исходящая, ТекВыборка.Идентификатор);
			
		КонецЦикла;
		
КонецПроцедуры	

// Процедура - Отправить исходящее сообщение 
//
// Параметры:
//  Идентификатор - УникальныйИдентификатор - Идентификатор сообщения
//  ИдентификаторСобытия - УникальныйИдентификатор - Идентификатор события
//  ФорматСообщения - Перечисление.сшпФорматыСообщений - Формат отправляемого сообщения
//	ТипОбъекта - Строка - Строковое представление имени метаданных объекта
//  МетодХранения - Перечисление.сшпМетодХранения - Метод хранения сообщения
//  ДатаРегистрации - Дата - Дата регистрации сообщения
//	ЭтоУдаление - Булево - Обозначение удаления
//	СсылкаНаОбъект - ЛюбаяСсылка - Ссылка на объект исходящего сообщения 
//
Процедура СформироватьИсходящееСообщение(Идентификатор, ИдентификаторСобытия, ФорматСообщения, ТипОбъекта, МетодХранения, ДатаРегистрации, ЭтоУдаление, СсылкаНаОбъект) Экспорт
	
	Если ИдетОбработкаСистемныхСобытий() Тогда
		
		Возврат; //Если включена обработка системных событий останавливаем рабочие потоки.
	
	КонецЕсли;
	
	СткОбработчик = сшпКэшируемыеФункции.ПолучитьОбработчик(Типобъекта, Перечисления.сшпТипыИнтеграции.Исходящая, сшпФункциональныеОпции.ВерсияОбработчиков());
	
	Если Не ЗначениеЗаполнено(СткОбработчик.ПроцедураОбработки) Тогда
		
		сшпРаботаСДанными.УстановитьСостояниеСообщения(ИдентификаторСобытия, Перечисления.сшпСтатусыСообщений.ОтсутствуетОбработчик, ,"В 1С отсутствует исходящий обработчик для " + Строка(ТипОбъекта) , , , Перечисления.сшпТипыИнтеграции.Исходящая);
	
	Иначе	
		
		Если СткОбработчик.Статус = Перечисления.сшпСтатусыОбработчиков.Отключен Тогда
			
			сшпРаботаСДанными.УстановитьСостояниеСообщения(ИдентификаторСобытия, Перечисления.сшпСтатусыСообщений.ОбработкаОтменена, ,"Обработка исходящего сообщения была отменена! Обработчик отключен!" , , , Перечисления.сшпТипыИнтеграции.Исходящая);
		
		Иначе
			
			Задержка = 0;
			ОписаниеОшибки = "";
			ОтменитьОтправку = Ложь;
			ТекЗаголовокЖурнала = "Datareon. Получение объекта события";
			ТекстОшибки = "";
			ДопСвойства = Неопределено;	
			
			Объектсобытия = ПолучитьОбъектСобытия(Перечисления.сшпТипыИнтеграции.Исходящая, ИдентификаторСобытия);
			
			ТекЗаголовокЖурнала = "Datareon. Формирование сообщения";
			
			РезультатОбработки = сшпОбщегоНазначения.СформироватьСтруктуруПакета();
			РезультатОбработки.Id = Идентификатор;
			
			Попытка
				
				СостояниеСообщения = Перечисления.сшпСтатусыСообщений.Обработано;
				ОбъектОбработки = Неопределено;
				
				Если МетодХранения = Перечисления.сшпМетодХранения.ПоСсылке Тогда
					
					Если ТипЗнч(ОбъектСобытия) = Тип("Отбор") Тогда
						
						ТипРегистра = сшпКэшируемыеФункции.ПолучитьТипОбъекта(ТипОбъекта);
						ИмяРегистра = сшпКэшируемыеФункции.ПолучитьИмяОбъекта(ТипОбъекта);
						
						Если ТипРегистра = "РегистрСведений" Тогда
							
							ОбъектОбработки = РегистрыСведений[ИмяРегистра].СоздатьНаборЗаписей();	
							
						ИначеЕсли ТипРегистра = "РегистрНакопления" Тогда
							
							ОбъектОбработки = РегистрыНакопления[ИмяРегистра].СоздатьНаборЗаписей();
							
						ИначеЕсли ТипРегистра = "РегистрБухгалтерии" Тогда
							
							ОбъектОбработки = РегистрыБухгалтерии[ИмяРегистра].СоздатьНаборЗаписей();
							
						ИначеЕсли ТипРегистра = "РегистрРасчета" Тогда
							
							ОбъектОбработки = РегистрыРасчета[ИмяРегистра].СоздатьНаборЗаписей();
							
						Иначе
							
							ВызватьИсключение "Тип: " + ТипРегистра + " не поддерживается текущей версией подсистемы ESB";
							
						КонецЕсли;
						
						Для Каждого ЭлементОтбор Из ОбъектСобытия Цикл
							
							ЗаполнитьЗначенияСвойств(ОбъектОбработки.Отбор[ЭлементОтбор.Имя], ЭлементОтбор);
						
						КонецЦикла;
						
						ОбъектОбработки.Прочитать();
					
					Иначе
						
						ОбъектОбработки = ОбъектСобытия;
						
					КонецЕсли;
					
				Иначе
						
					ОбъектОбработки = сшпОбщегоНазначения.ДесериализоватьОбъект(ФорматСообщения, ОбъектСобытия);
					
				КонецЕсли;
				
				НовыйСтатус = сшпОбщегоНазначения.ПолучитьСтатусСобытия(ИдентификаторСобытия);
				Если НовыйСтатус = Перечисления.сшпСтатусыСообщений.ПакетнаяОбработка Тогда
					Возврат;
				КонецЕсли;
				
				//++ Градум Гусев А.С. 05.05.2021
				ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле = ОценкаПроизводительности.НачатьЗамерВремени();
				//-- Градум Гусев А.С. 05.05.2021
								
				Выполнить(сткОбработчик.ПроцедураОбработки);
				
				//++ Градум Гусев А.С. 05.05.2021
				ОценкаПроизводительности.ЗакончитьЗамерВремени( грОбработкаПакетовИнтеграцииПовтИсп.ПолучитьПрефиксКлючевойОперации() 
						+ сткОбработчик.Наименование + " - общее время", ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле);
				//-- Градум Гусев А.С. 05.05.2021
				
				Если СостояниеСообщения = Перечисления.сшпСтатусыСообщений.Обработано Тогда
					
					сшпОбщегоНазначения.УстановитьСвойствоПоиска(СсылкаНаОбъект, РезультатОбработки);
					
					ТекЗаголовокЖурнала = "Datareon. Отправка сообщения";
					ТекВозврат = сшпВзаимодействиеСАдаптером.ОтправитьСообщениеБезОчереди(РезультатОбработки, СостояниеСообщения);
					
					Если Не ТекВозврат Тогда
						
						СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
						Задержка = 30;
						
					КонецЕсли;
					
				КонецЕсли;
				
			Исключение
				
				
				ТекстОшибки = сшпОбщегоНазначения.ПолучитьТекстОшибкиОбработчика(ИнформацияОбОшибке());
				//++ Градум Гусев А.С. 05.05.2021
				ДанныеДляКомментария = Новый Структура("ТекстОшибки", ТекстОшибки);
				ОценкаПроизводительности.ЗакончитьЗамерВремени( грОбработкаПакетовИнтеграцииПовтИсп.ПолучитьПрефиксКлючевойОперации() 
					+ сткОбработчик.Наименование + " - общее время, ошибка", ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле,, ДанныеДляКомментария);
				//-- Градум Гусев А.С. 05.05.2021
				ЗаписьЖурналаРегистрации(текЗаголовокЖурнала, УровеньЖурналаРегистрации.Ошибка, , ИдентификаторСобытия, ТекстОшибки);
				
				Если текЗаголовокЖурнала = "Datareon. Формирование сообщения" Тогда
					
					СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
										
				Иначе
					
					СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
					Задержка = 30;
					
				КонецЕсли;
					
			КонецПопытки;
			
			Если Не СостояниеСообщения = Перечисления.сшпСтатусыСообщений.Отправлено Тогда
					
				Если СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки Тогда
					ТекстОшибки = сшпОбщегоНазначения.ДополнитьТекстОшибки(ТекстОшибки, сткОбработчик, СсылкаНаОбъект);
					ДопСвойства = сшпОбщегоНазначения.ПолучитьИдентификаторОбъектаСобытия(Объектсобытия);
				КонецЕсли;
						
				сшпРаботаСДанными.УстановитьСостояниеСообщения(ИдентификаторСобытия, СостояниеСообщения, Задержка, ТекстОшибки, , , Перечисления.сшпТипыИнтеграции.Исходящая, Типобъекта, Идентификатор, ДопСвойства);
		
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Процедура - Обработать входящее сообщение 
//
// Параметры:
//  Идентификатор - УникальныйИдентификатор - Идентификатор сообщения
//  ФорматСообщения - Перечисление.сшпФорматыСообщений - Формат поступившего сообщения
//  КлассСообщения - Строка - Идентификатор класса поступившего сообщения, по данному классу выполняется получение обработчика для сообщения
//  ДатаРегистрации - Дата - Дата регистрации сообщения
//
Процедура ОбработатьВходящееСообщение(Идентификатор, ФорматСообщения, КлассСообщения, ДатаРегистрации) Экспорт
	
	Если ИдетОбработкаСистемныхСобытий() Тогда
		
		Возврат; //Если включена обработка системных событий останавливаем рабочие потоки.
	
	КонецЕсли;
	
	СткОбработчик = сшпКэшируемыеФункции.ПолучитьОбработчик(КлассСообщения, Перечисления.сшпТипыИнтеграции.Входящая, сшпФункциональныеОпции.ВерсияОбработчиков());
	
	Если Не ЗначениеЗаполнено(СткОбработчик.ПроцедураОбработки) Тогда
		
		сшпРаботаСДанными.УстановитьСостояниеСообщения(Идентификатор, Перечисления.сшпСтатусыСообщений.ОтсутствуетОбработчик, ,"В 1С отсутствует входящий обработчик для класса " + Строка(КлассСообщения) , , Ложь, Перечисления.сшпТипыИнтеграции.Входящая, КлассСообщения);
	
	Иначе
			
		Если сткОбработчик.Статус = Перечисления.сшпСтатусыОбработчиков.Отключен Тогда
			
			сшпРаботаСДанными.УстановитьСостояниеСообщения(Идентификатор, Перечисления.сшпСтатусыСообщений.ОбработкаОтменена, ,"Обработка исходящего сообщения была отменена! Обработчик отключен!" , , Ложь, Перечисления.сшпТипыИнтеграции.Входящая, КлассСообщения);
		
		Иначе
				
			Попытка
				
				Задержка = 0;
				текЗаголовокЖурнала = "Datareon. Получение объекта события";
				
				ОбъектСобытия = ПолучитьОбъектСобытия(Перечисления.сшпТипыИнтеграции.Входящая, Идентификатор);
				
				ИдШаблона = СткОбработчик.ИдентификаторШаблона;
				ВерсияШаблона = СткОбработчик.Версия;
				
				СостояниеСообщения = Перечисления.сшпСтатусыСообщений.Обработано; // Переменная для установки нового состояние сообщения
				ОбъектСообщение = сшпОбщегоНазначения.ПолучитьОбъектXDTO(ФорматСообщения, ОбъектСобытия);
						
				КоличествоПопытокОжидания = сшпОбщегоНазначения.ПолучитьКоличествоПопытокОжидания(ОбъектСообщение);		
				
				//++ Градум Гусев А.С. 05.05.2021
				ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле = ОценкаПроизводительности.НачатьЗамерВремени();
				//-- Градум Гусев А.С. 05.05.2021
				
				Выполнить(сткОбработчик.ПроцедураОбработки);
				
				//++ Градум Гусев А.С. 05.05.2021
				ОценкаПроизводительности.ЗакончитьЗамерВремени( грОбработкаПакетовИнтеграцииПовтИсп.ПолучитьПрефиксКлючевойОперации()
					+ сткОбработчик.Наименование + " - общее время", ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле);
				//-- Градум Гусев А.С. 05.05.2021
				
				сшпРаботаСДанными.УстановитьСостояниеСообщения(Идентификатор, СостояниеСообщения, Задержка, , , Ложь, Перечисления.сшпТипыИнтеграции.Входящая, КлассСообщения);
				
			Исключение
				
				ТекстОшибки = сшпОбщегоНазначения.ДополнитьТекстОшибки(сшпОбщегоНазначения.ПолучитьТекстОшибкиОбработчика(ИнформацияОбОшибке()), СткОбработчик, Неопределено);			
				ЗаписьЖурналаРегистрации("Datareon. Обработка сообщения", УровеньЖурналаРегистрации.Ошибка, , Идентификатор, ТекстОшибки);
				//++ Градум Гусев А.С. 05.05.2021
				ДанныеДляКомментария = Новый Структура("ТекстОшибки", ТекстОшибки);
				ОценкаПроизводительности.ЗакончитьЗамерВремени( грОбработкаПакетовИнтеграцииПовтИсп.ПолучитьПрефиксКлючевойОперации() 
					+ сткОбработчик.Наименование + " - общее время, ошибка", ЗамерОбщегоВремениРаботыОбработчикаВОбщемМодуле,, ДанныеДляКомментария);
				//-- Градум Гусев А.С. 05.05.2021
								
				сшпРаботаСДанными.УстановитьСостояниеСообщения(Идентификатор, Перечисления.сшпСтатусыСообщений.ОшибкаОбработки, , ТекстОшибки, , Ложь, Перечисления.сшпТипыИнтеграции.Входящая, КлассСообщения);
			
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Функция - Идет обработка системных событий
// 
// Возвращаемое значение:
// Булево  - Признак выполнения системных сообщений по изменению обработчиков.
//
Функция ИдетОбработкаСистемныхСобытий() Экспорт
	
	МсвКлючи = Новый Массив;
	МсвКлючи.Добавить("ВыполнитьИзменениеОбработчиков");
	
	КоличествоПотоков = сшпОбщегоНазначения.ПолучитьКоличествоПотоков("Ключ", МсвКлючи);
	
	Возврат Не КоличествоПотоков = 0; 

КонецФункции	

// Процедура - Выполнить изменение обработчиков
//
// Параметры:
//  Сообщения - ТаблицаЗначений - список событий по изменению обработчиков. 
//
Процедура ВыполнитьИзменениеОбработчиков(Сообщение) Экспорт
	
	#Область Ожидание //Ожидаем завершения текущих процессов обработки рабочих очередей.
	
	СчетчикПопытки = 100;
	
	Пока Истина = Истина Цикл
		
		МсвКлючи = Новый Массив;
		МсвКлючи.Добавить("ОтправитьСообщениеНаАдаптер");
		МсвКлючи.Добавить("ОбработатьСообщениеОтАдаптера");
		
		КоличествоПотоков = сшпОбщегоНазначения.ПолучитьКоличествоПотоков("Наименование", МсвКлючи);
		
		Если КоличествоПотоков = 0 Тогда
			
			Прервать;
			
		Иначе
			
			СчетчикПопытки = СчетчикПопытки - 1;
			
			Если СчетчикПопытки = 0 Тогда
				
				ЗаписьЖурналаРегистрации("Datareon. Обработка очереди системных сообщений", УровеньЖурналаРегистрации.Ошибка, , , "Не удалось дождаться остановки потоков обработки рабочих очередей.");
				Возврат;
				
			Иначе
					
				сшпОбщегоНазначения.Ожидание(5);
				
			КонецЕсли;
			
		КонецЕсли;
			
	КонецЦикла;
	
	#КонецОбласти
	
	ТекИдентификатор = "Идентификатор не определен";
			
	Попытка
		
		РезультатОперации = Истина;
		ТекИдентификатор = Сообщение.ИдентификаторСобытия;
		ТелоПакета = Сообщение.Хранилище.Получить();
		СтатусЗавершение = Перечисления.сшпСтатусыСообщений.Обработано;
				
		Если Сообщение.КлассСообщения = "TUM" Тогда

			РезультатОперации = сшпСистемныеСообщения.ОбновитьОбработчикСобытия(Сообщение.ФорматСообщения, ТелоПакета);

		ИначеЕсли Сообщение.КлассСообщения = "TCS" Тогда

			РезультатОперации = сшпСистемныеСообщения.УправлениеСостояниемОбработчика(Сообщение.ФорматСообщения, ТелоПакета);

		ИначеЕсли Сообщение.КлассСообщения = "TRM" Тогда

			РезультатОперации = сшпСистемныеСообщения.УдалитьОбработчикСобытия(Сообщение.ФорматСообщения, ТелоПакета);

		ИначеЕсли Сообщение.КлассСообщения = "FUM" Тогда
			
			результатОперации = сшпСистемныеСообщения.ОбновитьФункцию(Сообщение.ФорматСообщения, телоПакета);
		
		ИначеЕсли Сообщение.КлассСообщения = "FCS" Тогда
			
			результатОперации = сшпСистемныеСообщения.УправлениеСостояниемФункции(Сообщение.ФорматСообщения, телоПакета);
		
		ИначеЕсли Сообщение.КлассСообщения = "FRM" Тогда
			
			результатОперации = сшпСистемныеСообщения.УдалитьФункцию(Сообщение.ФорматСообщения, телоПакета);
		
		КонецЕсли;
		
		Если Не РезультатОперации Тогда
			
			СтатусЗавершение = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
			
		КонецЕсли;
			
	Исключение
		
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		СтатусЗавершение = Перечисления.сшпСтатусыСообщений.ОшибкаОбработки;
		ЗаписьЖурналаРегистрации("Datareon. Обработка очереди системных сообщений", УровеньЖурналаРегистрации.Ошибка, , ТекИдентификатор, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке));
	
	КонецПопытки;
		
КонецПроцедуры	

// Функция - Получить объект события
//
// Параметры:
//  ТипОчереди - Перечисление.сшпТипыИнтеграции - тип очереди из которой необходимо получить данные 
//  Идентификатор - УникальныйИдентификатор - идентификатор события по которому требуется получить данные. 
// 
// Возвращаемое значение:
//  Строка - данные события.
//
Функция ПолучитьОбъектСобытия(ТипОчереди, Идентификатор) Экспорт 
	
	ЗапросОбъектСобытия = Новый Запрос;
	ЗапросОбъектСобытия.Текст = "ВЫБРАТЬ
	|	тбОчередь.Хранилище
	|ИЗ
	|	РегистрСведений.сшпОчередьИсходящихСообщений КАК тбОчередь
	|ГДЕ
	|	тбОчередь.ИдентификаторСобытия = &Идентификатор";
	ЗапросОбъектСобытия.УстановитьПараметр("Идентификатор", Идентификатор);
	
	ЗапросВыборка = ЗапросОбъектСобытия.Выполнить().Выбрать();
	
	ЗапросВыборка.Следующий();
	
	Возврат ЗапросВыборка.Хранилище.Получить();
	
КонецФункции

// Процедура - Выполнить внешнюю команду
//
// Параметры:
//  Идентификатор - УникальныйИдентификатор - идентификатор текущей команды
//  ФорматСообщения - Перечисление.сшпФорматыСообщений - формат команды
//  XmlПакет - Строка - тело полученного сообщения команды.
//
Процедура ВыполнитьВнешнююКоманду(Идентификатор, ФорматСообщения, XmlПакет) Экспорт
	
	Если ПолучитьФункциональнуюОпцию("сшпИспользоватьСШП") И Не ПолучитьФункциональнуюОпцию("сшпОтключитьПотоки") Тогда
		
		XdtoТип 				= ФабрикаXDTO.Тип("http://esb.axelot.ru", "Message");
		XdtoПакет 				= сшпОбщегоНазначения.ПолучитьОбъектXDTO(форматсообщения, XmlПакет, XdtoТип);
		
		ОтправитьОтвет = Ложь;
		
		ТекЗаголовокЖурнала = "Datareon. Выполнение внешней команды";
		
		РезультатОбработки = сшпОбщегоНазначения.СформироватьСтруктуруПакета();
		
		Попытка
						
			Выполнить(xdtoПакет.Body);
			
			Если ОтправитьОтвет Тогда
				
				ТекЗаголовокЖурнала = "Datareon. Отправка сообщения";
				
				Если Константы.сшпТипИспользуемогоКоннектораESB.Получить() = Перечисления.сшпТипыКоннекторовESB.Pipe Тогда
				
					сшпPipe.ОтправитьСообщениеБезОчереди(РезультатОбработки);
				
				ИначеЕсли Константы.сшпТипИспользуемогоКоннектораESB.Получить() = Перечисления.сшпТипыКоннекторовESB.Tcp Тогда
					
					сшпTcp.ОтправитьСообщениеБезОчередиСлужебный(РезультатОбработки);
				
				Иначе
				
					сшпВзаимодействиеСАдаптером.ОтправитьСообщениеБезОчереди(РезультатОбработки);
					
				КонецЕсли;
				
			КонецЕсли;
			
		Исключение
			
			ИнформацияОшибка = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ЗаписьЖурналаРегистрации(ТекЗаголовокЖурнала, УровеньЖурналаРегистрации.Ошибка,, Идентификатор, ИнформацияОшибка);
			
			Если ТекЗаголовокЖурнала = "Datareon. Выполнение внешней команды" Тогда
				
				сткСвойства = сшпОбщегоНазначения.ПолучитьПараметрыСообщенияСтруктурой(XdtoПакет);
				сшпСистемныеСообщения.ОтправитьСообщениеОбОшибке("Command", ИнформацияОшибка, СткСвойства);
				
			КонецЕсли;
				
		КонецПопытки;
		
	КонецЕсли;
		
КонецПроцедуры

// Процедура - Установить параметры пользователя 
//
// Параметры:
//  Идентификатор - УникальныйИдентификатор - идентификатор текущей команды
//	СтруктураПараметров - Структура - структура параметров пользователя
//
Процедура УстановитьПараметрыПользователя(Идентификатор, СтруктураПараметров) Экспорт
	
	ПараметрыПользователяПолучены = СтруктураПараметров.Свойство("User") И СтруктураПараметров.Свойство("Password");
	ТекЗаголовокЖурнала = "Datareon. Установка параметров пользователя";
	
	Если Не ПараметрыПользователяПолучены Тогда
		
		ИнформацияОшибка = "Полученное сообщение SUS не содержит обязательных свойств User и Password";
		ЗаписьЖурналаРегистрации(текЗаголовокЖурнала, УровеньЖурналаРегистрации.Ошибка, , Идентификатор, ИнформацияОшибка);
		сшпСистемныеСообщения.ОтправитьСообщениеОбОшибке("SUS", ИнформацияОшибка, Новый Структура());
		
		Возврат;
	
	КонецЕсли;

	ИмяПользователя = СтруктураПараметров["User"];
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ИмяПользователя);
	
	Попытка
		
		Если ПользовательИБ = Неопределено Тогда
			
			НовыйПользователь = ПользователиИнформационнойБазы.СоздатьПользователя();
			НовыйПользователь.Имя = ИмяПользователя;
			НовыйПользователь.ПолноеИмя = ИмяПользователя;
			НовыйПользователь.Пароль = СтруктураПараметров["Password"];
			НовыйПользователь.АутентификацияСтандартная = Истина;
			НовыйПользователь.Роли.Добавить(Метаданные.Роли.сшпОбменСESB);
			НовыйПользователь.Записать();
		
		ИначеЕсли Не ПользовательИБ.Роли.Содержит(Метаданные.Роли.сшпОбменСESB) Тогда 
			
			ПользовательИБ.Роли.Добавить(Метаданные.Роли.сшпОбменСESB);
			ПользовательИБ.Записать();
		
		КонецЕсли;
		
	Исключение
		
		ИнформацияОшибка = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ЗаписьЖурналаРегистрации(ТекЗаголовокЖурнала, УровеньЖурналаРегистрации.Ошибка, , Идентификатор, ИнформацияОшибка);
		сшпСистемныеСообщения.ОтправитьСообщениеОбОшибке("SUS", ИнформацияОшибка, Новый Структура());
	
	КонецПопытки;

КонецПроцедуры

#КонецОбласти

#Область РаботаСФункциями

Функция ВыполнитьФункцию(ИмяФункции, ПараметрыФункции)

	Возврат сшпОбщегоНазначения.ВыполнитьФункцию(ИмяФункции, ПараметрыФункции);
	
КонецФункции

Функция ВыполнитьФункциюКэш(ИмяФункции, ПараметрыФункции)

	Возврат сшпОбщегоНазначения.ВыполнитьФункцию(ИмяФункции, ПараметрыФункции, Истина);
	
КонецФункции

#КонецОбласти