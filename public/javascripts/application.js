// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
I18n = {
	availableLocales: [],
	defaultLocale: 'nl',
	currentLocale: 'nl',
	locale: {},
	t: function(key, scope){ 
		if(I18n.availableLocales.indexOf(I18n.currentLocale) == -1) return I18n.currentLocale + ' translation missing!';		
		if(scope == null && I18n.locale[I18n.currentLocale][key]) return I18n.locale[I18n.currentLocale][key];
		else if(scope != null && I18n.locale[I18n.currentLocale][scope][key]) return I18n.locale[I18n.currentLocale][scope][key];
		else return 'missing: ' + key;
	}
};