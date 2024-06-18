// --------------------------------------------------------------------
//	音声データ変換ツール
// --------------------------------------------------------------------

#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cstring>

using namespace std;

#define PROGRAM_SIZE 6144
#define ROM_SIZE (1024 * 512)

typedef struct {
	int32_t		riff_id;
	int32_t		riff_size;
	int32_t		riff_type;
	int32_t		fmt_chank_id;
	int32_t		fmt_chank_size;
	int16_t		type;
	int16_t		channel;
	int32_t		sample;
	int32_t		byte_size;
	int16_t		sample_bytes;
	int16_t		sample_bits;
	int32_t		data_chank_id;
	int32_t		data_chank_size;
} WAV_HEADER_T;

// --------------------------------------------------------------------
static int convert_one( int d ) {
	//                                0    1    2     3     4     5     6     7     8     9     10     11     12     13     14     15
	static const int psg_level[] = { 362, 511, 724, 1023, 1448, 2047, 2896, 4095, 5792, 8191, 11585, 16383, 23170, 32767, 46340, 65535 };
	int i;

	d = d * 2 + 32768;
	for( i = 0; i < 15; i++ ) {
		if( d < psg_level[i] ) {
			break;
		}
	}
	return i;
}

// --------------------------------------------------------------------
static void convert( void ) {
	char s_buffer[128];
	FILE* p_file;
	int16_t* p_data;
	int samples;
	static WAV_HEADER_T header;
	static uint8_t result[ ROM_SIZE - PROGRAM_SIZE ];
	int i, l, h, s;

	sprintf( s_buffer, "voice.wav" );
	printf( "Read '%s' ... ", s_buffer );
	p_file = fopen( s_buffer, "rb" );
	if( p_file == NULL ) {
		printf( "[ERROR] Cannot open the '%s'.\n", s_buffer );
		exit( 1 );
	}
	fread( &header, sizeof( header ), 1, p_file );
	samples = ( header.data_chank_size - 16 ) / 2;
	p_data = (int16_t*)malloc( samples * 2 );
	if( p_data == NULL ) {
		printf( "[ERROR] Not enough memory.\n" );
		exit( 1 );
	}
	fread( p_data, samples, 2, p_file );
	fclose( p_file );
	printf( "OK\n" );
	printf( "Samples = %d\n", samples );
	printf( "Wave memory size = %d\n", (int)sizeof( result ) );

	memset( result, 0, sizeof( result ) );
	for( i = 0; i < sizeof(result); i++ ) {
		//	下位4bit
		s = (int)( (long long)(i * 2 + 0) * samples / (sizeof(result) * 2) );
		if( s >= samples ) {
			s = samples - 1;
		}
		l = convert_one( p_data[s] );
		//	上位4bit
		s = (int)( (long long)(i * 2 + 1) * samples / (sizeof(result) * 2) );
		if( s >= samples ) {
			s = samples - 1;
		}
		printf( "%d --> %d\r", s, i );
		h = convert_one( p_data[s] );
		//	result
		result[i] = (uint8_t)(l | ( h << 4 ));
	}
	printf( "%d --> %d\n", s, i );

	sprintf( s_buffer, "voise.bin" );
	printf( "Write '%s' ... ", s_buffer );
	p_file = fopen( s_buffer, "wb" );
	if( p_file == NULL ) {
		printf( "[ERROR] Cannot create the '%s'.\n", s_buffer );
		exit( 1 );
	}
	printf( "OK\n" );
	fwrite( result, sizeof(result), 1, p_file );
	fclose( p_file );
}

// --------------------------------------------------------------------
int main( int argc, char* argv[] ) {

	printf( "Voice Converter\n" );
	printf( "==========================================================\n" );
	printf( "2024 Copyright (C) t.hara\n" );

	convert();

	printf( "Completed.\n" );
	return 0;
}
