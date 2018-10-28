package asd.fgh.olduitable;
import javax.swing.JTextArea;

public class TextAreaComboBox extends DropDownButton{
    
    private JTextArea textArea;

    public TextAreaComboBox(JTextArea text_Area) {
		super();
		textArea = text_Area;		
    }

	public JTextArea getTextArea() {
		return textArea;
	}	
}