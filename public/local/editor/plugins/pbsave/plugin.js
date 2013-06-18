
// PowerBulletin Form Save Button

(function() {
	var saveCmd = { modes:{wysiwyg:1,source:1 },
		readOnly: 1,
		exec: function(editor) {
			var $form  = editor.element.$.form;
			if ($form.submit.click) // save!
        $form.body.value = editor.getData();
    		$form.submit.click();
		}
	};

	var pluginName = 'pbsave';

	CKEDITOR.plugins.add(pluginName, {
		icons: 'save',
		init: function(editor) {
			var command = editor.addCommand( pluginName, saveCmd );

			editor.ui.addButton && editor.ui.addButton('Save', {
				label: 'Save!',
				command: pluginName,
				toolbar: 'document,10'
			});
		}
	});
})();
