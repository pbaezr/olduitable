package asd.fgh.olduitable;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.event.*;
import javax.swing.BorderFactory.*;

public class DropDownButton extends JButton {	
	
	private JButton arrowButton = new JButton(); //"<html>&#9013;</html>"
	private JPopupMenu popup;
	private JLabel label = new JLabel("");

	public DropDownButton() {

		setFocusPainted(false);
		setOpaque(true);
		setBackground(Color.white);
		setContentAreaFilled(false);

		label.setOpaque(true);
		label.setBackground(Color.white);
		//label.setBorder(new CompoundBorder(new LineBorder(Color.white,2),new LineBorder(Color.black)));		
		
		arrowButton.setIcon(UIManager.getIcon("Table.descendingSortIcon"));
		arrowButton.setOpaque(true);
		arrowButton.setContentAreaFilled(false);
		arrowButton.setFocusPainted(false);
		arrowButton.setBorder(new EmptyBorder(0,0,0,1));		
		arrowButton.setPreferredSize(new Dimension(20, 0));		
		
		arrowButton.addChangeListener(new ChangeListener() {
			public void stateChanged(ChangeEvent evt) {
				if (arrowButton.getModel().isPressed()) {
					arrowButton.setContentAreaFilled(true);
				} else if (arrowButton.getModel().isRollover()) {
					arrowButton.setContentAreaFilled(true);						
				} else {
					arrowButton.setContentAreaFilled(false);
				}
			}
		});

		setLayout(new BorderLayout());
		setMargin(new Insets(-1, -1,-1,-3));

		add(label, BorderLayout.CENTER);
		add(arrowButton, BorderLayout.EAST);
	}	
	
	public void setPopupMenu(final JPopupMenu popupmenu) {
		popup = popupmenu;		
	}

	
	public JButton getArrowButton() {
		return arrowButton;
	}
	
	public JLabel getJLabel() {
		return label;
	}
	
	public JPopupMenu getPopupMenu() {
		return popup;
	}
	
	public void showPopup() {
		try {	
			popup.show(this, getWidth() - popup.getPreferredSize().width, getHeight());
			setSelected(true);
		}
		catch (Exception e) { // IllegalComponentStateException
		}
	}

	/*public void hidePopup() {
		popup.setVisible(false);
	}*/
}