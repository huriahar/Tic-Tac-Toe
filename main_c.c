int main()
{
	asm("call _main\n"
		"ret\n"
		::);
	return 0;
}
