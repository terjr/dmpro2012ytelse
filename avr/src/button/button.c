#include "button.h"

#include "board.h"
#include "gpio.h"
#include "intc.h"

#include "led.h" //TODO debug only

#define B0_VALUE gpio_get_pin_value(GPIO_PUSH_BUTTON_0)
#define B1_VALUE gpio_get_pin_value(GPIO_PUSH_BUTTON_1)
#define B2_VALUE gpio_get_pin_value(GPIO_PUSH_BUTTON_2)
#define B3_VALUE gpio_get_pin_value(GPIO_PUSH_BUTTON_3)

#define BUTTON_PUSHED 0
#define BUTTON_RELEASED 1


//#define MAX_LISTENERS 20
//void(*listeners[MAX_LISTENERS]) (U8);
volatile void(*listener)(U8);
volatile void(*old_listener)(U8);
//int n_listeners;

/*
 * Notifies all listeners of a button push
 */
void notify_listeners(U8 buttons) {
	if (listener) listener(buttons);
	//int i;
	//for (i = 0; i < n_listeners; ++i) {
		//listeners[i](buttons);
	//}
}
#include "serial.h"

__attribute__((__interrupt__)) void button_interrupt_routine(void) {
//	U8 buttons = 0;
	if (gpio_get_pin_interrupt_flag(GPIO_PUSH_BUTTON_0)) {
		gpio_clear_pin_interrupt_flag(GPIO_PUSH_BUTTON_0);
		if (listener) listener(1);
	} else if (gpio_get_pin_interrupt_flag(GPIO_PUSH_BUTTON_1)) {
		gpio_clear_pin_interrupt_flag(GPIO_PUSH_BUTTON_1);
		if (listener) listener(2);
	} else if (gpio_get_pin_interrupt_flag(GPIO_PUSH_BUTTON_2)) {
		gpio_clear_pin_interrupt_flag(GPIO_PUSH_BUTTON_2);
		if (listener) listener(4);
	} else if (gpio_get_pin_interrupt_flag(GPIO_PUSH_BUTTON_3)) {
		gpio_clear_pin_interrupt_flag(GPIO_PUSH_BUTTON_3);
		if (listener) listener(8);
	}

//	if (B0_VALUE == BUTTON_PUSHED) buttons |= 1;
//	if (B1_VALUE == BUTTON_PUSHED) buttons |= 2;
//	if (B2_VALUE == BUTTON_PUSHED) buttons |= 4;
//	if (B3_VALUE == BUTTON_PUSHED) buttons |= 8;
//
//	gpio_clear_pin_interrupt_flag(GPIO_PUSH_BUTTON_0);
//	gpio_clear_pin_interrupt_flag(GPIO_PUSH_BUTTON_1);
//	gpio_clear_pin_interrupt_flag(GPIO_PUSH_BUTTON_2);
//	gpio_clear_pin_interrupt_flag(GPIO_PUSH_BUTTON_3);
//
//	if (buttons) notify_listeners(buttons);
	return;
}

int button_init(void) {
	int rc;
	//n_listeners = 0;

	// Enable GPIO button pins
	gpio_enable_gpio_pin(GPIO_PUSH_BUTTON_0);
	gpio_enable_gpio_pin(GPIO_PUSH_BUTTON_1);
	gpio_enable_gpio_pin(GPIO_PUSH_BUTTON_2);
	gpio_enable_gpio_pin(GPIO_PUSH_BUTTON_3);

	// Enable glitch filter for all buttons
	gpio_enable_pin_glitch_filter(GPIO_PUSH_BUTTON_0);
	gpio_enable_pin_glitch_filter(GPIO_PUSH_BUTTON_1);
	gpio_enable_pin_glitch_filter(GPIO_PUSH_BUTTON_2);
	gpio_enable_pin_glitch_filter(GPIO_PUSH_BUTTON_3);

	// Enable pull up resistors
	gpio_enable_pin_pull_up(GPIO_PUSH_BUTTON_0);
	gpio_enable_pin_pull_up(GPIO_PUSH_BUTTON_1);
	gpio_enable_pin_pull_up(GPIO_PUSH_BUTTON_2);
	gpio_enable_pin_pull_up(GPIO_PUSH_BUTTON_3);

	// Register interrupt for buttons
	int b0_line = AVR32_GPIO_IRQ_0 + GPIO_PUSH_BUTTON_0 / 8;
	//int b1_b2_line = AVR32_GPIO_IRQ_0 + GPIO_PUSH_BUTTON_3 / 8;
	//if (b0_line == b1_b2_line) LED_On(LED0);
	//else LED_On(LED7);


	// Because the lines for button 1 and button 2 are equal,
	// the same interrupt vector are used.

	INTC_register_interrupt(&button_interrupt_routine, b0_line, AVR32_INTC_INT1);
	//INTC_register_interrupt(&button_interrupt_routine, b1_b2_line, AVR32_INTC_INT1);


	// GPIO enable interrupt of buttons on push
	rc = gpio_enable_pin_interrupt(GPIO_PUSH_BUTTON_0, GPIO_FALLING_EDGE);
	if (rc != GPIO_SUCCESS) return rc;
	rc = gpio_enable_pin_interrupt(GPIO_PUSH_BUTTON_1, GPIO_FALLING_EDGE);
	if (rc != GPIO_SUCCESS) return rc;
	rc = gpio_enable_pin_interrupt(GPIO_PUSH_BUTTON_2, GPIO_FALLING_EDGE);
	if (rc != GPIO_SUCCESS) return rc;
	rc = gpio_enable_pin_interrupt(GPIO_PUSH_BUTTON_3, GPIO_FALLING_EDGE);
	if (rc != GPIO_SUCCESS) return rc;

	return rc;
}

void button_reg_listener(void(*l) (U8)) {
	listener = l;
}

void button_set_tmp_listener(void(*l) (U8)) {
	old_listener = listener;
	if (l) listener = l;
	else LED_On(0xff);
}

void button_remove_tmp_listener(void) {
	listener = old_listener;
}

