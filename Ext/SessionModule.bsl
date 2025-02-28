﻿Процедура УстановкаПараметровСеанса(ТребуемыеПараметры)
	
	Имя = ПользователиИнформационнойБазы.ТекущийПользователь().Имя;
	ФизЛицо = Справочники.ФизическиеЛица.НайтиПоНаименованию(Имя, Истина);
	Если ФизЛицо.Пустая() Тогда
		ФизЛицоОбъект = Справочники.ФизическиеЛица.СоздатьЭлемент();
		ФизЛицоОбъект.Наименование = Имя;
		ФизЛицоОбъект.Записать();
		ФизЛицо = ФизЛицоОбъект.Ссылка;
	КонецЕсли;
    ПараметрыСеанса.ТекущийПользователь = ФизЛицо;

КонецПроцедуры
