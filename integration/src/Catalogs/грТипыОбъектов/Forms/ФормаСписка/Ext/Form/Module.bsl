﻿#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьАлгоритмыСборкиИзESB(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОбновитьИзESBНаСервереЗавершение", ЭтотОбъект );
	ПоказатьВопрос(ОписаниеОповещения, НСтр("ru='Обновить алгоритмы сборки из ESB?'"), РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Нет);
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ОбновитьИзESBНаСервереЗавершение( Результат, ДопПараметры ) Экспорт 
	
	Если Результат = КодВозвратаДиалога.Нет Тогда
		Возврат;
	КонецЕсли;
	
	ОбновитьИзESBНаСервере();
	Элементы.Список.Обновить();
	
КонецПроцедуры


&НаСервереБезКонтекста
Процедура ОбновитьИзESBНаСервере()
	
	ИмяНастройки = "ПрефиксОбработчиковСборки";
	ПрефиксКласса = Справочники.грНастройкиПоУмолчанию.ПолучитьЗначениеНастройки( ИмяНастройки );
	
	текЗапрос = Новый Запрос(
	"ВЫБРАТЬ
	|	тбРепозиторий.ИмяКлассаОбъекта КАК Наименование,
	|	тбРепозиторий.ПроцедураОбработки КАК АлгоритмОбработки,
	|	тбРепозиторий.Версия КАК Версия,
	|	тбРепозиторий.ИдентификаторШаблона КАК ИдентификаторШаблона
	|ПОМЕСТИТЬ ВТ_ИсходящиеОбработчики
	|ИЗ
	|	РегистрСведений.сшпРепозиторийОбъектовИнтеграции КАК тбРепозиторий
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.сшпСтатусыОбработчиков КАК тбСтатусы
	|		ПО тбРепозиторий.ИдентификаторШаблона = тбСтатусы.ИдентификаторОбработчика
	|			И (тбСтатусы.Статус = ЗНАЧЕНИЕ(Перечисление.сшпСтатусыОбработчиков.Включен))
	|ГДЕ
	|	тбРепозиторий.ИмяКлассаОбъекта ПОДОБНО ""//%1"" + ""%""
	|	И тбРепозиторий.ТипИнтеграции = ЗНАЧЕНИЕ(Перечисление.сшпТипыИнтеграции.Исходящая)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(грТипыОбъектов.Ссылка, ЗНАЧЕНИЕ(Справочник.грТипыОбъектов.ПустаяСсылка)) КАК Ссылка,
	|	ВТ_ИсходящиеОбработчики.Наименование КАК Наименование,
	|	ВТ_ИсходящиеОбработчики.АлгоритмОбработки КАК АлгоритмОбработки,
	|	ВТ_ИсходящиеОбработчики.Версия КАК Версия,
	|	ВТ_ИсходящиеОбработчики.ИдентификаторШаблона КАК ИдентификаторШаблона
	|ИЗ
	|	ВТ_ИсходящиеОбработчики КАК ВТ_ИсходящиеОбработчики
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.грТипыОбъектов КАК грТипыОбъектов
	|		ПО ВТ_ИсходящиеОбработчики.ИдентификаторШаблона = грТипыОбъектов.ИдентификаторШаблона");	
	
	текЗапрос.Текст = СтрЗаменить( текЗапрос.Текст, "//%1", ПрефиксКласса );
	
	Выборка = текЗапрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		Если Не ЗначениеЗаполнено( Выборка.Ссылка ) Тогда
			СпрОбъект = Справочники.грТипыОбъектов.СоздатьЭлемент();
		Иначе
			СпрОбъект = Выборка.Ссылка.ПолучитьОбъект();;
		КонецЕсли;
		
		ЗаполнитьЗначенияСвойств( СпрОбъект, Выборка );
		СпрОбъект.Наименование = СтрЗаменить( Выборка.Наименование, ПрефиксКласса, "");
		СпрОбъект.Записать();
		
	КонецЦикла;

КонецПроцедуры;

#КонецОбласти
