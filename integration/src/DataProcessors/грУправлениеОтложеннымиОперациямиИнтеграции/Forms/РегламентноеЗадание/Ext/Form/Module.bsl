﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если НЕ Пользователи.ЭтоПолноправныйПользователь(, Истина) Тогда
		ВызватьИсключение НСтр("ru = 'Недостаточно прав доступа.
		                             |
		                             |Изменение свойств регламентного задания
		                             |выполняется только администраторами.'");
	КонецЕсли;
	
	Действие = Параметры.Действие;
	
	Если СтрНайти(", Добавить, Скопировать, Изменить,", ", " + Действие + ",") = 0 Тогда
		
		ВызватьИсключение НСтр("ru = 'Неверные параметры открытия формы ""Регламентное задание"".'");
	КонецЕсли;
	
	Если Действие = "Добавить" Тогда
		
		ПараметрыОтбора        = Новый Структура;
		ПараметризуемыеЗадания = Новый Массив;
		ЗависимостиЗаданий     = РегламентныеЗаданияСлужебный.РегламентныеЗаданияЗависимыеОтФункциональныхОпций();
		
		ПараметрыОтбора.Вставить("Параметризуется", Истина);
		РезультатПоиска = ЗависимостиЗаданий.НайтиСтроки(ПараметрыОтбора);
		
		Для Каждого СтрокаТаблицы Из РезультатПоиска Цикл
			ПараметризуемыеЗадания.Добавить(СтрокаТаблицы.РегламентноеЗадание);
		КонецЦикла;
		
		Расписание = Новый РасписаниеРегламентногоЗадания;
		
		РегламентноеЗаданиеМетаданные = Метаданные.РегламентныеЗадания.Найти("грОтложенныеОперацииИнтеграции");
		
		ОписанияМетаданныхРегламентныхЗаданий.Добавить(
				РегламентноеЗаданиеМетаданные.Имя
					+ Символы.ПС
					+ РегламентноеЗаданиеМетаданные.Синоним
					+ Символы.ПС
					+ РегламентноеЗаданиеМетаданные.ИмяМетода,
				?(ПустаяСтрока(РегламентноеЗаданиеМетаданные.Синоним),
				  РегламентноеЗаданиеМетаданные.Имя,
				  РегламентноеЗаданиеМетаданные.Синоним) );
				  
		Размер		= 1000;
		Количество	= 10000;
		
	Иначе
		
		Задание = РегламентныеЗаданияСервер.ПолучитьРегламентноеЗадание(Параметры.Идентификатор);
		ЗаполнитьЗначенияСвойств(
			ЭтотОбъект,
			Задание,
			"Ключ,
			|Предопределенное,
			|Использование,
			|Наименование,
			|ИмяПользователя,
			|ИнтервалПовтораПриАварийномЗавершении,
			|КоличествоПовторовПриАварийномЗавершении");
		
		Идентификатор = Строка(Задание.УникальныйИдентификатор);
		Если Задание.Метаданные = Неопределено Тогда
			ИмяМетаданных        = НСтр("ru = '<нет метаданных>'");
			СинонимМетаданных    = НСтр("ru = '<нет метаданных>'");
			ИмяМетодаМетаданных  = НСтр("ru = '<нет метаданных>'");
		Иначе
			ИмяМетаданных        = Задание.Метаданные.Имя;
			СинонимМетаданных    = Задание.Метаданные.Синоним;
			ИмяМетодаМетаданных  = Задание.Метаданные.ИмяМетода;
		КонецЕсли;
		Расписание = Задание.Расписание;
		
		СообщенияПользователюИОписаниеИнформацииОбОшибке = РегламентныеЗаданияСлужебный
			.СообщенияИОписанияОшибокРегламентногоЗадания(Задание);
			
		ПараметрыЗадания = Задание.Параметры;
		
		Для Каждого ЭлементПараметры Из ПараметрыЗадания Цикл
			
			Если ТипЗнч(ЭлементПараметры) = Тип("Соответствие")
				И ЭлементПараметры.Количество() Тогда
				Для Каждого КлючЗначение Из ЭлементПараметры Цикл
					МетодОтложеннойОперации = КлючЗначение.Ключ;
					Если ТипЗнч(КлючЗначение.Значение) = Тип("Структура")
						И КлючЗначение.Значение.Свойство("ПараметрыПорций") Тогда
						
						КлючЗначение.Значение.ПараметрыПорций.Свойство("Размер",		Размер);
						КлючЗначение.Значение.ПараметрыПорций.Свойство("Количество",	Количество);
						КлючЗначение.Значение.ПараметрыПорций.Свойство("ДатаНачала",	ДатаНачала);
						КлючЗначение.Значение.ПараметрыПорций.Свойство("ДатаОкончания",	ДатаОкончания);
						
						Если ЗначениеЗаполнено(ДатаНачала)
							Или ЗначениеЗаполнено(ДатаОкончания) Тогда
							ИспользоватьПериод = Истина;
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
		
	КонецЕсли;
	
	Если Действие <> "Изменить" Тогда
		Идентификатор = НСтр("ru = '<будет создан при записи>'");
		Использование = Ложь;
		
		Наименование = ?(
			Действие = "Добавить",
			"",
			РегламентныеЗаданияСлужебный.ПредставлениеРегламентногоЗадания(Задание));
	КонецЕсли;
	
	// Заполнение списка выбора имени пользователя.
	МассивПользователей = ПользователиИнформационнойБазы.ПолучитьПользователей();
	
	Для каждого Пользователь Из МассивПользователей Цикл
		Элементы.ИмяПользователя.СписокВыбора.Добавить(Пользователь.Имя);
	КонецЦикла;
	
	СтандартныеПодсистемыСервер.УстановитьОтображениеЗаголовковГрупп(ЭтотОбъект);
КонецПроцедуры 

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Действие = "Добавить" Тогда
		ПодключитьОбработчикОжидания("ВыборШаблонаНовогоРегламентногоЗадания", 0.1, Истина);
	Иначе
		ОбновитьЗаголовокФормы();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Оповещение = Новый ОписаниеОповещения("ЗаписатьИЗакрытьЗавершение", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияФормы(Оповещение, Отказ, ЗавершениеРаботы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура НаименованиеПриИзменении(Элемент)
	
	ОбновитьЗаголовокФормы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Записать(Команда)
	
	ЗаписатьРегламентноеЗадание();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрытьВыполнить()
	
	Если Не ЗначениеЗаполнено(МетодОтложеннойОперации) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнен Метод отложенной операции",, "МетодОтложеннойОперации");
		Возврат;
	КонецЕсли;
	
	ЗаписатьИЗакрытьЗавершение();
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьРасписаниеВыполнить()

	Диалог = Новый ДиалогРасписанияРегламентногоЗадания(Расписание);
	Диалог.Показать(Новый ОписаниеОповещения("ОткрытьРасписаниеЗавершение", ЭтотОбъект));
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаписатьИЗакрытьЗавершение(Результат = Неопределено, ДополнительныеПараметры = Неопределено) Экспорт
	
	Если Не ЗначениеЗаполнено(МетодОтложеннойОперации) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнен Метод отложенной операции",, "МетодОтложеннойОперации");
		Возврат;
	КонецЕсли;
	
	ЗаписатьРегламентноеЗадание();
	Модифицированность = Ложь;
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборШаблонаНовогоРегламентногоЗадания()
	
	// Выбор шаблона регламентного задания (метаданные).
	Если ОписанияМетаданныхРегламентныхЗаданий.Количество() = 1 Тогда
		ВыборШаблонаНовогоРегламентногоЗаданияЗавершение(ОписанияМетаданныхРегламентныхЗаданий[0], Неопределено);
	Иначе
		ОписанияМетаданныхРегламентныхЗаданий.ПоказатьВыборЭлемента(
			Новый ОписаниеОповещения("ВыборШаблонаНовогоРегламентногоЗаданияЗавершение", ЭтотОбъект),
			НСтр("ru = 'Выберите шаблон регламентного задания'"));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборШаблонаНовогоРегламентногоЗаданияЗавершение(ЭлементСписка, Контекст) Экспорт
	
	Если ЭлементСписка = Неопределено Тогда
		Закрыть();
		Возврат;
	КонецЕсли;
	
	ИмяМетаданных       = СтрПолучитьСтроку(ЭлементСписка.Значение, 1);
	СинонимМетаданных   = СтрПолучитьСтроку(ЭлементСписка.Значение, 2);
	ИмяМетодаМетаданных = СтрПолучитьСтроку(ЭлементСписка.Значение, 3);
	Наименование        = ЭлементСписка.Представление;
	
	ОбновитьЗаголовокФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьРасписаниеЗавершение(НовоеРасписание, Контекст) Экспорт

	Если НовоеРасписание <> Неопределено Тогда
		Расписание = НовоеРасписание;
		Модифицированность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьРегламентноеЗадание()
	
	Если НЕ ЗначениеЗаполнено(ИмяМетаданных) Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(МетодОтложеннойОперации) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнен Метод отложенной операции",, "МетодОтложеннойОперации");
		Возврат;
	КонецЕсли;
	
	ТекущийИдентификатор = ?(Действие = "Изменить", Идентификатор, Неопределено);
	
	ЗаписатьРегламентноеЗаданиеНаСервере();
	ОбновитьЗаголовокФормы();
	
	Оповестить("Запись_РегламентныеЗадания", ТекущийИдентификатор);
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьРегламентноеЗаданиеНаСервере()
	
	Если Действие = "Изменить" Тогда
		Задание = РегламентныеЗаданияСервер.ПолучитьРегламентноеЗадание(Идентификатор);
	Иначе
		ПараметрыЗадания = Новый Структура;
		ПараметрыЗадания.Вставить("Метаданные", Метаданные.РегламентныеЗадания[ИмяМетаданных]);
		
		Задание = РегламентныеЗаданияСервер.ДобавитьЗадание(ПараметрыЗадания);
		
		Идентификатор = Строка(Задание.УникальныйИдентификатор);
		Действие = "Изменить";
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(
		Задание,
		ЭтотОбъект,
		"Ключ, 
		|Наименование,
		|Использование,
		|ИмяПользователя,
		|ИнтервалПовтораПриАварийномЗавершении,
		|КоличествоПовторовПриАварийномЗавершении");
	
	Задание.Расписание = Расписание;
	
	УстановитьПараметрыНаСервере(Задание);
	
	Задание.Записать();
	
	Модифицированность = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЗаголовокФормы()
	
	Если НЕ ПустаяСтрока(Наименование) Тогда
		Представление = Наименование;
		
	ИначеЕсли НЕ ПустаяСтрока(СинонимМетаданных) Тогда
		Представление = СинонимМетаданных;
	Иначе
		Представление = ИмяМетаданных;
	КонецЕсли;
	
	Если Действие = "Изменить" Тогда
		Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1 (Регламентное задание)'"), Представление);
	Иначе
		Заголовок = НСтр("ru = 'Регламентное задание (создание)'");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрыНаСервере(Задание)

	Соответствие = грОтложенныеОперацииИнтеграцииКлиентСервер.ПараметрыЗапускаРегламентныхЗаданий();
	
	СтруктураПараметров = Соответствие.Получить(МетодОтложеннойОперации);
	СтруктураПараметров.Вставить("Отборы", Новый Структура);
	
	ПараметрыПорций = Новый Структура("Размер, Количество", Размер, Количество);
	
	Если ИспользоватьПериод Тогда
		ПараметрыПорций.Вставить("ДатаНачала",		ДатаНачала);
		ПараметрыПорций.Вставить("ДатаОкончания",	КонецДня(ДатаОкончания));
	КонецЕсли;
	
	СтруктураПараметров.Вставить("ПараметрыПорций", ПараметрыПорций);
	
	ВыполнитьСборкуСоответствие = Новый Соответствие;
	ВыполнитьСборкуСоответствие.Вставить(МетодОтложеннойОперации, СтруктураПараметров);
		
	мсвПараметры = Новый Массив;
	мсвПараметры.Добавить(ВыполнитьСборкуСоответствие);
	Задание.Параметры = мсвПараметры;

КонецПроцедуры // УстановитьПараметрыНаСервере()


#КонецОбласти
