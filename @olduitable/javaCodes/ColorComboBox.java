package asd.fgh.olduitable;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.event.*;
import javax.swing.BorderFactory.*;

public class ColorComboBox extends DropDownButton {	

	private JPopupMenu popup;
	private Component[] colors;
	//private Color pickedColor;	
	private int storedColor = 55; // by default, the last color in the pallete (white)
	private int targetedItem = -1; // current targeted color
	private CompoundBorder exitColor = new CompoundBorder(new LineBorder(new Color(240,240,240),3), new LineBorder(Color.black));					
	private CompoundBorder overColor = new CompoundBorder(new CompoundBorder(new LineBorder(new Color(0,114,189)),new LineBorder(new Color(145,201,247),2)), new LineBorder(Color.black));

	public ColorComboBox() {
		super();
		
		getJLabel().setBorder(new CompoundBorder(new LineBorder(Color.white,2),new LineBorder(new Color(51, 51, 51))));		

		getArrowButton().addMouseWheelListener(new MouseWheelListener() {			
			public void mouseWheelMoved(MouseWheelEvent e) {
				setSelected(false);			
			}
		});
		
		getArrowButton().addKeyListener(new KeyListener() {
			public void keyPressed(KeyEvent e) {
				if (popup.isVisible() && targetedItem > -1)
					((JMenuItem)popup.getComponent(targetedItem)).setBorder(exitColor);
				setSelected(false);			
			}
			public void keyTyped(KeyEvent e) {}
			public void keyReleased(KeyEvent e) {}
		});

	}	

	public void highlightSavedColor() {
		if (storedColor != -1) ((JMenuItem)colors[storedColor]).setBorder(exitColor);		
		storedColor = -1;
		
		for(int i = 0; i < colors.length - 2; i++) {
			if (getJLabel().getBackground().equals(colors[i].getBackground())) {
				((JMenuItem)colors[i]).setBorder(overColor);
				storedColor = i;
				break;
			}
		}
	}
	
	@Override
	public void setPopupMenu(final JPopupMenu popupmenu) {		
		popup = popupmenu;
		colors = popup.getComponents();
		
		MouseListener listener = new MouseListener() {							
			public void mousePressed(MouseEvent evt) {
				JMenuItem colorsh = (JMenuItem)evt.getSource();
				getJLabel().setBackground(colorsh.getBackground());
				popup.setVisible(false);
				setSelected(false);
				colorsh.setBorder(exitColor);
				//pickedColor = colorsh.getBackground();
			}
			
			public void mouseEntered(MouseEvent evt) {				
				JMenuItem colorsh = (JMenuItem)evt.getSource();				
				colorsh.setBorder(overColor);
				targetedItem = popup.getComponentIndex(colorsh);
			}
			
			public void mouseExited(MouseEvent evt) {				
				JMenuItem colorsh = (JMenuItem)evt.getSource();				
				if (storedColor == -1 || !colorsh.equals(colors[storedColor]))
					colorsh.setBorder(exitColor);
			}
			
			public void mouseReleased(MouseEvent evt) {
				((JMenuItem)evt.getSource()).setBorder(exitColor);
			}
			
			public void mouseClicked(MouseEvent evt) {}
		};
		
		MouseWheelListener wheellistener = new MouseWheelListener() {
			public void mouseWheelMoved(MouseWheelEvent e) {				
				((JMenuItem)e.getSource()).setBorder(exitColor);
				setSelected(false);			
			}
		};
		
		for(int i = 0; i < colors.length - 2; i++) {
			colors[i].setEnabled(false);
			colors[i].addMouseListener(listener);
			colors[i].addMouseWheelListener(wheellistener);
		}		
	}
	
	@Override
	public void showPopup() {
		try {
			highlightSavedColor();
			popup.show(this, getWidth() - popup.getPreferredSize().width, getHeight());
			setSelected(true);
			getArrowButton().requestFocus();
		}
		catch (Exception e) { // IllegalComponentStateException
		}	
	}
}