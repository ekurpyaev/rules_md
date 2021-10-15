xdtoДокумент = сшпОбщегоНазначения.ПолучитьОбъектXDTO(ФорматСообщения, ОбъектСообщение.Body);
ПараметрыОбработки = грОбработкаПакетовИнтеграции.ПолучитьПараметрыОбработкиСообщения(ОбъектСообщение, xdtoДокумент);

ВидИдентификатора = "УНИКУМGUID";
ИмяТипаОбъекта = "Документ.СписаниеНедостачТоваров";

ТаблицаИдентификаторовПотоков = грОбработкаПакетовИнтеграцииПовтИсп.ПолучитьТаблицуИдентификаторыПотоковESB();
НенайденныеОбъекты = грОбработкаПакетовИнтеграции.СоздатьТаблицуНенайденныхОбъектов();

КэшСсылок = Новый Соответствие;
КоличествоЗаписейВБлоке = 0;

// +++ Включение отложенных дозапросов
ПараметрыОбработки.ВыполнятьДозапросы = Ложь;
// --- Включение отложенных дозапросов

НачатьТранзакцию();

Попытка
	
	Последовательность = xdtoДокумент.Список.Последовательность();
	
	//+++Логирование прогресса загрузки
	КоличествоЭлементов = Последовательность.Количество();
	ЗагруженоОбъектов = 0;
	//---Логирование прогресса загрузки
	
	//++ОтложенноеПроведениеДокументов.  
	СписокДокументов_ОбработкаПроведения = Новый Массив;
	//--ОтложенноеПроведениеДокументов. 
	
	Для Индекс = 0 По Последовательность.Количество()-1 Цикл
		xdtoОбъект = Последовательность.ПолучитьЗначение(Индекс);
		
		Ключ = xdtoОбъект.Ссылка;
		
		// Блокировка 
		Если НЕ грОбработкаПакетовИнтеграции.ЗаблокироватьКлючСПопытками(
			Ключ, ВидИдентификатора, ПараметрыОбработки.КоличествоПопытокБлокировки
			) Тогда 
			
			Если ПараметрыОбработки.МассоваяЗагрузка Тогда 
				ВызватьИсключение "Не удалось выполнить блокировку!";
			Иначе
				ОтменитьТранзакцию();
				СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
				Задержка = ПараметрыОбработки.ЗадержкаПриНеудачнойБлокировке;
				Перейти ~Возврат;
			КонецЕсли;
		КонецЕсли;
		
		//+++ Отложенные дозапросы
		ДопПараметрыДозапросов = Новый Структура;
		ДопПараметрыДозапросов.Вставить( "ID",  Ключ );
		ДопПараметрыДозапросов.Вставить( "Класс", КлассСообщения );
		//--- Отложенные дозапросы
		
		ВерсияОбъекта = грОбработкаПакетовИнтеграции.ЗначениеРеквизита(xdtoОбъект, "Версия", "Число",, 0);
		
		сткРезультатПоиска = грОбработкаПакетовИнтеграции.ПолучитьОбъектПоКлючуТПК(
		Ключ, ИмяТипаОбъекта, ВидИдентификатора, ПараметрыОбработки, ВерсияОбъекта);
		
		Если НЕ сткРезультатПоиска.ИзменениеРазрешено Тогда 
			Продолжить;
		КонецЕсли;
		
		//+++ Сборщик.Формирование интеграционного инкремента
		НаименованиеТипаОбъекта = "Документ.Списание";
		ПараметрыВходящегоПакета = Новый Структура("КлючОснования", Ключ); 
		Выполнить(грОбработкаПакетовИнтеграции.ПолучитьТекстОбработчика("Служебный_СформироватьВходящийПакетОбъектаЕРП", 
			Перечисления.сшпТипыИнтеграции.Исходящая));
		//--- Сборщик.Формирование интеграционного инкремента	
				
		ДокСсылка = сткРезультатПоиска.Ссылка;
		Если ЗначениеЗаполнено(ДокСсылка) Тогда
			ДокОбъект = ДокСсылка.ПолучитьОбъект();
		Иначе
			ДокОбъект = Документы.СписаниеНедостачТоваров.СоздатьДокумент();
		КонецЕсли;
		
		ДокОбъект.ВидДеятельностиНДС = Перечисления.ТипыНалогообложенияНДС.ПустаяСсылка();
		ДокОбъект.ВидЦены = Справочники.ВидыЦен.НайтиПоНаименованию("Базовая опт", Истина);
		ДокОбъект.ВидыЗапасовУказаныВручную = Ложь;
		ДокОбъект.ИсточникИнформацииОЦенахДляПечати = Перечисления.ИсточникиИнформацииОЦенахДляПечати.ПоВидуЦен;
		
		грОбработкаПакетовИнтеграции.ЗаполнитьЗначениемЕслиРеквизитЕстьВПакете(ДокОбъект, xdtoОбъект, "Дата", "Дата",, ТекущаяДата());
		грОбработкаПакетовИнтеграции.ЗаполнитьЗначениемЕслиРеквизитЕстьВПакете(ДокОбъект.грНомерУникум, xdtoОбъект, "Номер");
		грОбработкаПакетовИнтеграции.ЗаполнитьЗначениемЕслиРеквизитЕстьВПакете(ДокОбъект, xdtoОбъект, "ПометкаУдаления");
		грОбработкаПакетовИнтеграции.ЗаполнитьЗначениемЕслиРеквизитЕстьВПакете(ДокОбъект.грПроведенВременная, xdtoОбъект, "Проведен");
		грОбработкаПакетовИнтеграции.ЗаполнитьЗначениемЕслиРеквизитЕстьВПакете(ДокОбъект.грРегл, xdtoОбъект, "Регл", "Булево");
		
		грОбработкаПакетовИнтеграции.УстановитьРеквизитПеречисление( ДокОбъект, "грЕГАИСПричинаСписания", Перечисления.ПричиныСписанийЕГАИС, xdtoОбъект, "ЕГАИСПричинаСписания", ТекстОшибки );
		
		ДокОбъект.Организация = грОбработкаПакетовИнтеграции.НайтиОбъектПоКлючу(
		xdtoОбъект.Организация, 
		"Справочник.Организации", 
		ВидИдентификатора,
		"228",
		НенайденныеОбъекты,
		КэшСсылок, ДопПараметрыДозапросов);
		
		ДокОбъект.Ответственный = грОбработкаПакетовИнтеграции.НайтиОбъектПоКлючу(
		xdtoОбъект.Ответственный, 
		"Справочник.Пользователи", 
		ВидИдентификатора,
		"319",
		НенайденныеОбъекты,
		КэшСсылок, ДопПараметрыДозапросов);
		
		ДокОбъект.ПересчетТоваров = грОбработкаПакетовИнтеграции.НайтиОбъектПоКлючу(
		xdtoОбъект.ПересчетТоваров, 
		"Документ.ПересчетТоваров", 
		ВидИдентификатора,
		"307",
		НенайденныеОбъекты,
		КэшСсылок, ДопПараметрыДозапросов);
				
		КлючДепартаментЛогистики = " 4NF    9J001";
		ДокОбъект.Подразделение = грОбработкаПакетовИнтеграции.НайтиОбъектПоКлючу(
		КлючДепартаментЛогистики, 
		"Справочник.СтруктураПредприятия", 
		ВидИдентификатора,
		"294",
		НенайденныеОбъекты,
		КэшСсылок, ДопПараметрыДозапросов); 
		
		ДокОбъект.Склад = грОбработкаПакетовИнтеграции.НайтиОбъектПоКлючу(
		xdtoОбъект.Склад, 
		"Справочник.Склады", 
		ВидИдентификатора,
		"338",
		НенайденныеОбъекты,
		КэшСсылок, ДопПараметрыДозапросов);
		
		ДокОбъект.грПомещение = грОбработкаПакетовИнтеграции.НайтиОбъектПоКлючу(
		xdtoОбъект.Помещение, 
		"Справочник.СкладскиеПомещения", 
		ВидИдентификатора,
		"299",
		НенайденныеОбъекты,
		КэшСсылок, ДопПараметрыДозапросов);
		
				
		Комментарий = Неопределено;
		грОбработкаПакетовИнтеграции.ЗаполнитьЗначениемЕслиРеквизитЕстьВПакете(Комментарий, xdtoОбъект, "Комментарий");
		ДокОбъект.Комментарий = "<Документ Списание № " + ДокОбъект.грНомерУникум + " от " + ДокОбъект.Дата +" загружен из базы 1С:Уникум>" + Комментарий;
		
		ХозяйственнаяОперация = Неопределено;
		грОбработкаПакетовИнтеграции.ЗаполнитьЗначениемЕслиРеквизитЕстьВПакете(ХозяйСтвеннаяОперация, xdtoОбъект, "ХозяйственнаяОперация", "Строка");
		Если ХозяйственнаяОперация = "Списание с ЕГАИС" Тогда
			ДокОбъект.грСЕГАИС = Истина;
		Иначе
			ДокОбъект.грСЕГАИС = Ложь;
		КонецЕсли;	
		
		ДокОбъект.Товары.Очистить();
		
		Товары = грОбработкаПакетовИнтеграции.ТаблицаЗначенийПоТабличнойЧасти(ИмяТипаОбъекта, "Товары", "Номенклатура, грАГТ, Количество, грКачествоТоваров, грПричинаСписания, грВложенностьВКороб");
		xdtoТовары = xdtoОбъект.Товары.Последовательность();	
		Для ИндексТаблицы = 0 По xdtoТовары.Количество()-1 Цикл
			xdtoСтрока = xdtoТовары.ПолучитьЗначение(ИндексТаблицы);
			Стр = Товары.Добавить();
			
			Стр.Номенклатура = грОбработкаПакетовИнтеграции.НайтиОбъектПоКлючу(
			xdtoСтрока.Номенклатура, 
			"Справочник.Номенклатура", 
			ВидИдентификатора,
			"263",
			НенайденныеОбъекты,
			КэшСсылок, ДопПараметрыДозапросов);
			
			грОбработкаПакетовИнтеграции.ЗаполнитьЗначениемЕслиРеквизитЕстьВПакете(Стр, xdtoСтрока, "Количество", "Число");
			
			сткРезультатПоиска = грОбработкаПакетовИнтеграции.ПолучитьОбъектПоКлючуТПК(
			xdtoСтрока.Качество, "Справочник.грКачествоТоваров", ВидИдентификатора, ПараметрыОбработки);
			
			Качество = сткРезультатПоиска.Ссылка;
			Если Качество = Неопределено Тогда
				Качество = Справочники.грКачествоТоваров.Кондиция;
			КонецЕсли;	
			Стр.грКачествоТоваров = Качество;
			
			ПричинаСписания = грОбработкаПакетовИнтеграции.ЗначениеРеквизита( xdtoСтрока, "ПричинаСписания" );
			Если ЗначениеЗаполнено( ПричинаСписания ) Тогда
				Стр.грПричинаСписания = ОбщегоНазначенияКлиентСервер.ПредопределенныйЭлемент( "Справочник.грПричиныСписанияАП." + ПричинаСписания );
			КонецЕсли;
			
			Стр.грВложенностьВКороб = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Стр.Номенклатура,"грНормаВложенности");
			
		КонецЦикла;
		
		МассивНоменклатуры = Товары.ВыгрузитьКолонку("Номенклатура");
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Товары", Товары);
		Запрос.УстановитьПараметр("ТаблицаSKU", грОбработкаПакетовИнтеграции.ТаблицаSKUАГТ(ДокОбъект.Дата, МассивНоменклатуры));
		Запрос.УстановитьПараметр("Упаковки", грОбработкаПакетовИнтеграции.ТаблицаУпаковокНоменклатуры(МассивНоменклатуры));
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Товары.Номенклатура КАК Номенклатура,
		|	Товары.Количество КАК Количество,
		|	Товары.грПричинаСписания КАК грПричинаСписания,
		|	Товары.грКачествоТоваров КАК грКачествоТоваров,
		|	Товары.грВложенностьВКороб КАК грВложенностьВКороб
		|ПОМЕСТИТЬ втТовары
		|ИЗ
		|	&Товары КАК Товары
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТаблицаSKU.Номенклатура КАК Номенклатура,
		|	ТаблицаSKU.АГТ КАК АГТ
		|ПОМЕСТИТЬ втТаблицаSKU
		|ИЗ
		|	&ТаблицаSKU КАК ТаблицаSKU
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Упаковки.Номенклатура КАК Номенклатура,
		|	Упаковки.УпаковкаШтука КАК УпаковкаШтука,
		|	Упаковки.УпаковкаКороб КАК УпаковкаКороб,
		|	Упаковки.УпаковкаПаллет КАК УпаковкаПаллет
		|ПОМЕСТИТЬ втУпаковки
		|ИЗ
		|	&Упаковки КАК Упаковки
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура
		|;
		|		
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втТаблицаSKU.АГТ КАК грАГТ,
		|	втТовары.Номенклатура КАК Номенклатура,
		|	втТовары.грВложенностьВКороб КАК грВложенностьВКороб,
		|	втУпаковки.УпаковкаШтука КАК Упаковка,
		|	14 КАК СтатусУказанияСерий,
		|	втТовары.Количество КАК Количество,
		|	втТовары.грКачествоТоваров КАК грКачествоТоваров,
		|	втТовары.грПричинаСписания КАК грПричинаСписания
		|ИЗ
		|	втТовары КАК втТовары
		|		ЛЕВОЕ СОЕДИНЕНИЕ втТаблицаSKU КАК втТаблицаSKU
		|		ПО втТовары.Номенклатура = втТаблицаSKU.Номенклатура
		|		ЛЕВОЕ СОЕДИНЕНИЕ втУпаковки КАК втУпаковки
		|		ПО втТовары.Номенклатура = втУпаковки.Номенклатура";
		
		
		РезультатЗапроса = Запрос.Выполнить();
		ДокОбъект.Товары.Загрузить(РезультатЗапроса.Выгрузить());
				
		Если ПараметрыОбработки.ИспользоватьНумерациюУникум Тогда
			 ДокОбъект.Номер = ДокОбъект.грНомерУникум;
		Иначе
			ДокОбъект.УстановитьНовыйНомер();
		КонецЕсли;
				
		Если ДокОбъект.грПроведенВременная
			И Не ДокОбъект.ПометкаУдаления Тогда 
			СписокДокументов_ОбработкаПроведения.Добавить(ДокОбъект);
		КонецЕсли;	
		Если Не ДокОбъект.ЭтоНовый() Тогда 
			ОбменДаннымиСервер.УдалитьДвиженияУДокумента(ДокОбъект);
		КонецЕсли;	
		ДокОбъект.Проведен = Ложь;
		
		ДокОбъект.ОбменДанными.Загрузка = Истина;
		ДокОбъект.ДополнительныеСвойства.Вставить("СШПНеобрабатывать", Истина);
		ДокОбъект.Записать();
				
		грОбработкаПакетовИнтеграции.УстановитьКлюч_v2(
			ДокОбъект.Ссылка, 
			Ключ, 
			ПараметрыОбработки.Отправитель,  
			новый Структура(
			"ВидИдентификатораСтрока, ДатаОбновления, Версия",
			ВидИдентификатора,
			ПараметрыОбработки.ВремяПакета, ВерсияОбъекта));
		
		грОбработкаПакетовИнтеграции.УдалитьЗаписьОДозапросе(Ключ, "219" );
		
		//+++ Сборщик.Запуск сборки
		спрИмяТипаОбъекта = "Документ.Списание";
		ИдентификаторОбъекта = Ключ;
		Выполнить(грОбработкаПакетовИнтеграции.ПолучитьТекстОбработчика("ВыполнитьАлгоритмСборки", 
			Перечисления.сшпТипыИнтеграции.Исходящая));
		//--- Сборщик. Запуск сборки
		
		// +++ Отложенные дозапросы
		ДопПараметрыЗаписиДозапросов = Новый Структура;
		ДопПараметрыЗаписиДозапросов.Вставить( "Дата", ДокОбъект.Дата);
		грОбработкаПакетовИнтеграции.ЗаписатьОтложенныеДозапросы( Ключ, ИмяТипаОбъекта, КлассСообщения, xdtoОбъект, ПараметрыОбработки, НенайденныеОбъекты , ДопПараметрыЗаписиДозапросов);
		// --- Отложенные дозапросы
				
		// Конец изменения объекта
		
		КоличествоЗаписейВБлоке = КоличествоЗаписейВБлоке + 1;
		
		Если ПараметрыОбработки.МассоваяЗагрузка И КоличествоЗаписейВБлоке = ПараметрыОбработки.РазмерБлока Тогда 
			
			Если ПараметрыОбработки.ВыполнятьДозапросы И НенайденныеОбъекты.Количество() > 0 Тогда 
				грОбработкаПакетовИнтеграции.СоздатьДозапросыПоТаблице(
				НенайденныеОбъекты, 
				ПараметрыОбработки.ТаймаутДозапроса, 
				ПараметрыОбработки.КоличествоПопытокБлокировки, 
				ТаблицаИдентификаторовПотоков);
			КонецЕсли;
			
			Пока ТранзакцияАктивна() Цикл
				ЗафиксироватьТранзакцию();
			КонецЦикла;
			
			//+++Логирование прогресса загрузки
			ЗагруженоОбъектов = ЗагруженоОбъектов + КоличествоЗаписейВБлоке;
			ОсталосьОбработать = КоличествоЭлементов - ЗагруженоОбъектов;
			
			ТекстСообщения = СтрШаблон( "Загружено %1 объектов из %2, остаток %3, класс %4, сообщение %5", ЗагруженоОбъектов, КоличествоЭлементов, ОсталосьОбработать, КлассСообщения, Идентификатор);
				
			сшпОбщегоНазначения.ЗарегистрироватьЗаписьВЖурнале(УровеньЖурналаРегистрации.Предупреждение,
						 грОбработкаПакетовИнтеграции.ИмяСобытияОбработкиПакета(), ТекстСообщения, "" + Идентификатор);
			//---Логирование прогресса загрузки
			
			КоличествоЗаписейВБлоке = 0;
			НачатьТранзакцию();
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если ПараметрыОбработки.ВыполнятьДозапросы И НенайденныеОбъекты.Количество() > 0 Тогда 
		грОбработкаПакетовИнтеграции.СоздатьДозапросыПоТаблице(
		НенайденныеОбъекты, 
		ПараметрыОбработки.ТаймаутДозапроса, 
		ПараметрыОбработки.КоличествоПопытокБлокировки, 
		ТаблицаИдентификаторовПотоков);
		СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
		Задержка = ПараметрыОбработки.ЗадержкаПриДозапросе;
	КонецЕсли;
	
	Пока ТранзакцияАктивна() Цикл
		ЗафиксироватьТранзакцию();
	КонецЦикла;
	
	Если НенайденныеОбъекты.Количество() > 0 Тогда 
		
		Если ПараметрыОбработки.МассоваяЗагрузка Тогда 
			грОбработкаПакетовИнтеграции.ОбработатьИсключениеНенайденныхОбъектов( Идентификатор, НенайденныеОбъекты, ПараметрыОбработки);
		Иначе
			Если ПараметрыОбработки.ВыполнятьДозапросы Тогда 
				ДостигнутТаймаут = грОбработкаПакетовИнтеграции.ОпределитьТаймаутСообщения(
				КоличествоПопытокОжидания, 
				ДатаРегистрации, 
				ПараметрыОбработки);
				Если ДостигнутТаймаут Тогда 
					УровеньЖР = УровеньЖурналаРегистрации.Ошибка;
					ВызватьИсключение "Истекло время ожидания ответов на дозапросы. См. журнал регистрации.";
				Иначе
					УровеньЖР = УровеньЖурналаРегистрации.Предупреждение;
				КонецЕсли;
				грОбработкаПакетовИнтеграции.ЗаписатьНенайденныеОбъектыВЖР(НенайденныеОбъекты, Идентификатор,, УровеньЖР);
			Иначе
				грОбработкаПакетовИнтеграции.ОбработатьИсключениеНенайденныхОбъектов( Идентификатор, НенайденныеОбъекты, ПараметрыОбработки);
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
	//++ОтложенноеПроведениеДокументов.
	Выполнить(грОбработкаПакетовИнтеграции.ПолучитьТекстОбработчика("Служебный_ПроведениеДокументовЕРП", Перечисления.сшпТипыИнтеграции.Исходящая));
	//--ОтложенноеПроведениеДокументов. 
		
Исключение
	
	Пока ТранзакцияАктивна() Цикл
		ОтменитьТранзакцию();
	КонецЦикла;
	
	ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	
	Если Найти(ТекстОшибки,"Ошибка блокировки") > 0 Тогда 
		СостояниеСообщения = Перечисления.сшпСтатусыСообщений.ОжиданиеОбработки;
		Задержка = ПараметрыОбработки.ЗадержкаПриНеудачнойБлокировке;
	Иначе
		ВызватьИсключение
		"Ошибка в Datareon при загрузке объекта «" + ИмяТипаОбъекта + "». ID: " + ОбъектСообщение.ID 
		+ ". " + ТекстОшибки;
	КонецЕсли;
	
КонецПопытки;

~Возврат:

Пока ТранзакцияАктивна() Цикл
	ОтменитьТранзакцию();
КонецЦикла;


