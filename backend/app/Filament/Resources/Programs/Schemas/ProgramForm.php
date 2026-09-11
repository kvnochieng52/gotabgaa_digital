<?php

namespace App\Filament\Resources\Programs\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TimePicker;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Illuminate\Support\Str;

class ProgramForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Program')
                    ->columns(2)
                    ->schema([
                        TextInput::make('title')
                            ->required()
                            ->maxLength(150)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn ($state, callable $set, $context) => $context === 'create' ? $set('slug', Str::slug((string) $state)) : null)
                            ->columnSpanFull(),

                        TextInput::make('slug')->required()->columnSpanFull(),

                        TextInput::make('host')->required()->maxLength(120),

                        Select::make('type')
                            ->options(['tv' => 'TV', 'radio' => 'Radio'])
                            ->required()
                            ->native(false),

                        Textarea::make('description')->rows(2)->columnSpanFull(),
                    ]),

                Section::make('Schedule')
                    ->columns(3)
                    ->schema([
                        Select::make('day')
                            ->options([
                                'Monday' => 'Monday', 'Tuesday' => 'Tuesday', 'Wednesday' => 'Wednesday',
                                'Thursday' => 'Thursday', 'Friday' => 'Friday',
                                'Saturday' => 'Saturday', 'Sunday' => 'Sunday',
                            ])
                            ->required()
                            ->native(false),

                        TimePicker::make('start_time')
                            ->seconds(false)
                            ->required(),

                        TimePicker::make('end_time')
                            ->seconds(false)
                            ->required(),
                    ]),

                Section::make('Media & status')
                    ->columns(2)
                    ->schema([
                        FileUpload::make('image')->image()->directory('programs'),
                        Toggle::make('active')->default(true),
                    ]),
            ]);
    }
}
