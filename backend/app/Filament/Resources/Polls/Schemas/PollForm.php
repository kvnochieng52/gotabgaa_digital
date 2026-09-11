<?php

namespace App\Filament\Resources\Polls\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Illuminate\Support\Str;

class PollForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Poll question')
                    ->columns(2)
                    ->schema([
                        TextInput::make('question')
                            ->required()
                            ->maxLength(220)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn ($state, callable $set, $context) => $context === 'create' ? $set('slug', Str::slug((string) $state)) : null)
                            ->columnSpanFull(),

                        TextInput::make('slug')->required()->columnSpanFull(),
                    ]),

                Section::make('Options')
                    ->columnSpanFull()
                    ->schema([
                        Repeater::make('options')
                            ->schema([
                                TextInput::make('id')
                                    ->required()
                                    ->maxLength(50)
                                    ->helperText('Machine-readable option id (kebab-case).'),
                                TextInput::make('label')
                                    ->required()
                                    ->maxLength(160)
                                    ->columnSpan(2),
                                TextInput::make('votes')
                                    ->numeric()
                                    ->default(0)
                                    ->disabled(),
                            ])
                            ->columns(4)
                            ->minItems(2)
                            ->maxItems(6)
                            ->reorderable()
                            ->collapsible()
                            ->itemLabel(fn (array $state): ?string => $state['label'] ?? null),
                    ]),

                Section::make('Status')
                    ->columns(2)
                    ->schema([
                        Toggle::make('active')->default(true),
                        DateTimePicker::make('closes_at')
                            ->helperText('When voting closes. Leave blank for open-ended.'),
                    ]),
            ]);
    }
}
